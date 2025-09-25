import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals: { safeGetSession, supabase }, cookies }) => {
	const { session, user } = await safeGetSession();

	// Get user profile data if logged in
	let profile = null;
	if (user) {
		const { data } = await supabase
			.from('profiles')
			.select('username, full_name')
			.eq('id', user.id)
			.single();
		profile = data;
	}

	return {
		session,
		user,
		profile,
		cookies: cookies.getAll()
	};
};
