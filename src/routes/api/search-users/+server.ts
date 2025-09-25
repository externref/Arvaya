import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		// Get search query
		const query = url.searchParams.get('q');
		if (!query || query.trim().length < 2) {
			return json({ users: [] });
		}

		const searchTerm = query.trim().toLowerCase();

		// Search users by username with case-insensitive partial matching
		const { data: users, error: searchError } = await supabase
			.from('profiles')
			.select('username, full_name, profile_image_url')
			.ilike('username', `%${searchTerm}%`)
			.not('username', 'is', null)
			.not('id', 'eq', user.id) // Exclude current user from results
			.order('username')
			.limit(10); // Limit results to prevent overwhelming the UI

		if (searchError) {
			console.error('User search error:', searchError);
			throw error(500, 'Search failed');
		}

		return json({
			success: true,
			users: users || []
		});
	} catch (err) {
		console.error('Search users error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to search users');
	}
};