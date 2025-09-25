import { redirect } from '@sveltejs/kit';

export const load = async ({ locals: { supabase, safeGetSession } }) => {
	const { session, user } = await safeGetSession();

	// Redirect to auth if not logged in
	if (!session) {
		redirect(303, '/auth');
	}

	// Get user profile data to access username
	let profile = null;
	if (user) {
		const { data } = await supabase
			.from('profiles')
			.select('username, full_name, profile_image_url')
			.eq('id', user.id)
			.single();
		profile = data;
	}

	return {
		session,
		user,
		profile
	};
};
