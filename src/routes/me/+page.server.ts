import { redirect, fail } from '@sveltejs/kit';

// Helper function to calculate profile completion percentage
function calculateProfileCompletion(profile: any): number {
	if (!profile) return 0;
	
	let completedFields = 0;
	const totalFields = 7;
	
	if (profile.full_name && profile.full_name.trim()) completedFields++;
	if (profile.username && profile.username.trim()) completedFields++;
	if (profile.gender) completedFields++;
	if (profile.date_of_birth) completedFields++;
	if (profile.state) completedFields++;
	if (profile.tags && profile.tags.trim()) completedFields++;
	if (profile.bio && profile.bio.trim()) completedFields++;
	
	return Math.round((completedFields / totalFields) * 100);
}

export const load = async ({ locals: { supabase, safeGetSession } }) => {
	const { session, user } = await safeGetSession();

	// Redirect to auth if not logged in
	if (!session || !user) {
		redirect(303, '/auth');
	}

	// Try to load existing profile data with completion percentage
	let profile = null;
	let completionPercentage = 0;
	try {
		const { data, error } = await supabase.from('profiles').select('*').eq('id', user.id).single();

		if (!error && data) {
			profile = data;
			// Calculate completion percentage
			completionPercentage = calculateProfileCompletion(data);
		} else if (error && error.code === 'PGRST116') {
			// Profile doesn't exist, create it
			const { error: createError } = await supabase
				.rpc('handle_new_user_manually', {
					user_id: user.id,
					user_email: user.email || '',
					display_name: user.user_metadata?.full_name || ''
				});

			if (!createError) {
				// Fetch the newly created profile
				const { data: newProfile } = await supabase.from('profiles').select('*').eq('id', user.id).single();
				if (newProfile) {
					profile = newProfile;
					completionPercentage = calculateProfileCompletion(newProfile);
				}
			}
		}
	} catch (err) {
		console.log('Profile handling error:', err);
	}

	return {
		session,
		user,
		profile,
		completionPercentage
	};
};

export const actions = {
	updateProfile: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session, user } = await safeGetSession();

		if (!session || !user) {
			redirect(303, '/auth');
		}

		const formData = await request.formData();
		const fullName = formData.get('fullName') as string;
		const username = formData.get('username') as string;
		const gender = formData.get('gender') as string;
		const dateOfBirth = formData.get('dateOfBirth') as string;
		const state = formData.get('state') as string;
		const tags = formData.get('tags') as string;
		const bio = formData.get('bio') as string;

		// Basic validation
		if (!fullName || !username) {
			return fail(400, {
				errors: {
					fullName: !fullName ? 'Full name is required' : null,
					username: !username ? 'Username is required' : null
				},
				data: {
					fullName,
					username,
					gender,
					dateOfBirth,
					state,
					tags,
					bio
				}
			});
		}

		// Check if username is already taken by another user
		if (username) {
			const { data: existingUser } = await supabase
				.from('profiles')
				.select('id')
				.eq('username', username)
				.neq('id', user.id)
				.single();

			if (existingUser) {
				return fail(400, {
					errors: {
						username: 'Username is already taken'
					},
					data: {
						fullName,
						username,
						gender,
						dateOfBirth,
						state,
						tags,
						bio
					}
				});
			}
		}

		// Prepare profile data
		const profileData = {
			id: user.id,
			full_name: fullName,
			username: username,
			gender: gender || null,
			date_of_birth: dateOfBirth || null,
			state: state || null,
			tags: tags || null,
			bio: bio || null,
			updated_at: new Date().toISOString()
		};

		// Update or insert profile
		const { error } = await supabase.from('profiles').upsert(profileData);

		if (error) {
			console.error('Profile update error:', error);
			return fail(500, {
				error: 'Failed to update profile. Please try again.'
			});
		}

		// Also update the user metadata in auth
		const { error: authError } = await supabase.auth.updateUser({
			data: {
				full_name: fullName,
				date_of_birth: dateOfBirth || null
			}
		});

		if (authError) {
			console.error('Auth metadata update error:', authError);
			// Don't fail the whole operation if auth metadata update fails
		}

		return {
			success: true
		};
	},

	// Server actions for testing activity metrics (would normally be automatic)
	incrementBlogs: async ({ locals: { supabase, safeGetSession } }) => {
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			return fail(401, { error: 'Not authenticated' });
		}

		const { error } = await supabase.rpc('increment_blog_count', { user_id: user.id });
		if (error) {
			console.error('Error incrementing blog count:', error);
			return fail(500, { error: 'Failed to update blog count' });
		}

		return { success: true, message: 'Blog count incremented!' };
	},

	incrementPlaces: async ({ locals: { supabase, safeGetSession } }) => {
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			return fail(401, { error: 'Not authenticated' });
		}

		const { error } = await supabase.rpc('increment_places_explored', { user_id: user.id });
		if (error) {
			console.error('Error incrementing places explored:', error);
			return fail(500, { error: 'Failed to update places explored' });
		}

		return { success: true, message: 'Places explored incremented!' };
	},

	incrementEndorsements: async ({ locals: { supabase, safeGetSession } }) => {
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			return fail(401, { error: 'Not authenticated' });
		}

		const { error } = await supabase.rpc('increment_endorsements', { user_id: user.id });
		if (error) {
			console.error('Error incrementing endorsements:', error);
			return fail(500, { error: 'Failed to update endorsements' });
		}

		return { success: true, message: 'Endorsements incremented!' };
	},

	addActivityPoints: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			return fail(401, { error: 'Not authenticated' });
		}

		const formData = await request.formData();
		const points = parseInt(formData.get('points') as string) || 10;

		const { error } = await supabase.rpc('add_activity_points', {
			user_id: user.id,
			points_to_add: points
		});

		if (error) {
			console.error('Error adding activity points:', error);
			return fail(500, { error: 'Failed to add activity points' });
		}

		return { success: true, message: `Added ${points} activity points!` };
	}
};
