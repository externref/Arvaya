import { redirect } from '@sveltejs/kit';

export const load = async ({ locals: { supabase, safeGetSession } }) => {
	const { session, user } = await safeGetSession();

	// Redirect to auth if not logged in
	if (!session) {
		redirect(303, '/auth');
	}

	return {
		session,
		user
	};
};
