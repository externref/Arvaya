import { redirect, fail } from '@sveltejs/kit';

export const load = async ({ locals: { supabase, safeGetSession } }) => {
	const { session, user } = await safeGetSession();

	// Redirect to auth if not logged in
	if (!session || !user) {
		redirect(303, '/auth');
	}

	// Try to load existing profile data
	let profile = null;
	try {
		const { data, error } = await supabase.from('profiles').select('*').eq('id', user.id).single();

		if (!error) {
			profile = data;
		}
	} catch (err) {
		// Profile might not exist yet, that's okay
		console.log('Profile not found, will create new one');
	}

	return {
		session,
		user,
		profile
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
	}
};
