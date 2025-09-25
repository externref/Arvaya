import { error } from '@sveltejs/kit';

export const load = async ({ params, locals: { supabase, safeGetSession } }) => {
	const { username } = params;
	const { session, user: currentUser } = await safeGetSession();

	// Debug logging
	console.log('Profile route accessed with username:', username);
	console.log('Username type:', typeof username);
	console.log('Username length:', username?.length);

	if (!username || username.trim() === '') {
		console.log('Username validation failed');
		throw error(404, 'Username not provided');
	}

	// Fetch profile by username using public_profiles view (bypasses RLS issues)
	let { data: profile, error: profileError } = await supabase
		.from('public_profiles')
		.select('*')
		.eq('username', username)
		.single();

	// Fallback: try direct profiles table if view doesn't work
	if (profileError || !profile) {
		const { data: fallbackProfile, error: fallbackError } = await supabase
			.from('profiles')
			.select('*')
			.eq('username', username)
			.single();

		if (fallbackProfile && !fallbackError) {
			profile = fallbackProfile;
			profileError = fallbackError;
		}
	}

	if (profileError || !profile) {
		throw error(404, `Profile with username "${username}" not found`);
	}

	// Additional check for empty username in database
	if (!profile.username || profile.username.trim() === '') {
		throw error(404, 'Profile has no username set');
	}

	// Check if this is the current user's own profile
	const isOwnProfile = currentUser?.id === profile.id;

	// Parse tags into array
	const tags = profile.tags ? profile.tags.split(',').filter((tag: string) => tag.trim()) : [];

	// Calculate profile completion percentage
	const fields = [
		profile.full_name,
		profile.username,
		profile.gender,
		profile.date_of_birth,
		profile.state,
		profile.bio,
		tags.length > 0
	];
	const completedFields = fields.filter((field) => field).length;
	const completionPercentage = Math.round((completedFields / fields.length) * 100);

	// Calculate age if date_of_birth is available
	let age = null;
	if (profile.date_of_birth) {
		const birthDate = new Date(profile.date_of_birth);
		const today = new Date();
		age = today.getFullYear() - birthDate.getFullYear();
		const monthDiff = today.getMonth() - birthDate.getMonth();
		if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
			age--;
		}
	}

	// Calculate days since joining (created_at)
	let daysSinceJoining = null;
	if (profile.created_at) {
		const joinDate = new Date(profile.created_at);
		const today = new Date();
		const timeDiff = today.getTime() - joinDate.getTime();
		daysSinceJoining = Math.floor(timeDiff / (1000 * 3600 * 24));
	}

	return {
		profile: {
			...profile,
			tags,
			age,
			daysSinceJoining,
			completionPercentage
		},
		isOwnProfile,
		currentUser
	};
};
