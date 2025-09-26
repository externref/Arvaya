import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication (optional for viewing endorsements)
		const { session, user } = await safeGetSession();

		const userId = url.searchParams.get('user_id');
		const page = parseInt(url.searchParams.get('page') || '1');
		const limit = parseInt(url.searchParams.get('limit') || '10');
		const offset = (page - 1) * limit;

		if (!userId) {
			throw error(400, 'User ID is required');
		}

		// Get endorsements for the user with endorser details
		const { data: endorsements, error: endorsementsError } = await supabase
			.from('endorsements')
			.select(`
				id,
				created_at,
				endorser:endorser_id (
					id,
					username,
					full_name,
					profile_image_url
				)
			`)
			.eq('endorsed_id', userId)
			.order('created_at', { ascending: false })
			.range(offset, offset + limit - 1);

		if (endorsementsError) {
			console.error('Endorsements fetch error:', endorsementsError);
			throw error(500, 'Failed to fetch endorsements');
		}

		// Get total count for pagination
		const { count, error: countError } = await supabase
			.from('endorsements')
			.select('*', { count: 'exact', head: true })
			.eq('endorsed_id', userId);

		if (countError) {
			console.error('Endorsements count error:', countError);
		}

		return json({
			success: true,
			endorsements: endorsements || [],
			total: count || 0,
			page,
			limit,
			has_more: (count || 0) > page * limit
		});
	} catch (err) {
		console.error('Get endorsements error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to get endorsements');
	}
};