import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		const { endorsed_user_id } = await request.json();

		if (!endorsed_user_id) {
			throw error(400, 'Endorsed user ID is required');
		}

		// Prevent self-endorsement
		if (endorsed_user_id === user.id) {
			throw error(400, 'Cannot endorse yourself');
		}

		// Check if endorsement already exists
		const { data: existingEndorsement } = await supabase
			.from('endorsements')
			.select('id')
			.eq('endorser_id', user.id)
			.eq('endorsed_id', endorsed_user_id)
			.single();

		if (existingEndorsement) {
			throw error(400, 'You have already endorsed this user');
		}

		// Verify the endorsed user exists
		const { data: endorsedUser, error: userError } = await supabase
			.from('profiles')
			.select('id, username, full_name')
			.eq('id', endorsed_user_id)
			.single();

		if (userError || !endorsedUser) {
			throw error(404, 'User not found');
		}

		// Create the endorsement
		const { error: insertError } = await supabase
			.from('endorsements')
			.insert({
				endorser_id: user.id,
				endorsed_id: endorsed_user_id
			});

		if (insertError) {
			console.error('Endorsement creation error:', insertError);
			throw error(500, 'Failed to create endorsement');
		}

		return json({
			success: true,
			message: `Successfully endorsed ${endorsedUser.full_name || endorsedUser.username}`
		});
	} catch (err) {
		console.error('Endorse user error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to endorse user');
	}
};

export const DELETE: RequestHandler = async ({ request, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		const { endorsed_user_id } = await request.json();

		if (!endorsed_user_id) {
			throw error(400, 'Endorsed user ID is required');
		}

		// Find and delete the endorsement
		const { error: deleteError } = await supabase
			.from('endorsements')
			.delete()
			.eq('endorser_id', user.id)
			.eq('endorsed_id', endorsed_user_id);

		if (deleteError) {
			console.error('Endorsement deletion error:', deleteError);
			throw error(500, 'Failed to remove endorsement');
		}

		return json({
			success: true,
			message: 'Endorsement removed successfully'
		});
	} catch (err) {
		console.error('Remove endorsement error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to remove endorsement');
	}
};

export const GET: RequestHandler = async ({ url, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		const userId = url.searchParams.get('user_id');
		if (!userId) {
			throw error(400, 'User ID is required');
		}

		// Check if current user has endorsed this user
		const { data: endorsement } = await supabase
			.from('endorsements')
			.select('id')
			.eq('endorser_id', user.id)
			.eq('endorsed_id', userId)
			.single();

		// Get endorsement count and details for the user
		const { data: userProfile } = await supabase
			.from('profiles')
			.select('endorsements, username, full_name')
			.eq('id', userId)
			.single();

		return json({
			success: true,
			has_endorsed: !!endorsement,
			endorsement_count: userProfile?.endorsements || 0,
			user: userProfile
		});
	} catch (err) {
		console.error('Get endorsement status error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to get endorsement status');
	}
};