import { put, del } from '@vercel/blob';
import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { BLOB_READ_WRITE_TOKEN } from '$env/static/private';


export const POST: RequestHandler = async ({ request, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		// Parse the form data
		const formData = await request.formData();
		const file = formData.get('file') as File;

		if (!file) {
			throw error(400, 'No file provided');
		}

		// Validate file type
		if (!file.type.startsWith('image/')) {
			throw error(400, 'File must be an image');
		}

		// Validate file size (5MB limit)
		const MAX_SIZE = 5 * 1024 * 1024; // 5MB
		if (file.size > MAX_SIZE) {
			throw error(400, 'File size must be less than 5MB');
		}

		// Generate unique filename
		const fileExtension = file.name.split('.').pop() || 'jpg';
		const fileName = `profile-pictures/${user.id}-${Date.now()}.${fileExtension}`;

		// Get current profile to check for existing image
		const { data: currentProfile } = await supabase
			.from('profiles')
			.select('profile_image_url')
			.eq('id', user.id)
			.single();

		// Delete old image if it exists
		if (currentProfile?.profile_image_url) {
			try {
				await del(currentProfile.profile_image_url, {
					token: BLOB_READ_WRITE_TOKEN
				});
			} catch (delError) {
				console.warn('Failed to delete old profile image:', delError);
				// Continue with upload even if deletion fails
			}
		}

		// Upload to Vercel Blob
		const blob = await put(fileName, file, {
			access: 'public',
			token: BLOB_READ_WRITE_TOKEN
		});

		// Update profile with new image URL
		const { error: updateError } = await supabase
			.from('profiles')
			.update({
				profile_image_url: blob.url,
				updated_at: new Date().toISOString()
			})
			.eq('id', user.id);

		if (updateError) {
			// If database update fails, try to clean up the uploaded file
			try {
				await del(blob.url, { token: BLOB_READ_WRITE_TOKEN });
			} catch (cleanupError) {
				console.error('Failed to cleanup uploaded file after database error:', cleanupError);
			}
			throw error(500, 'Failed to update profile');
		}

		return json({
			success: true,
			imageUrl: blob.url,
			message: 'Profile picture updated successfully'
		});
	} catch (err) {
		console.error('Profile picture upload error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to upload profile picture');
	}
};

export const DELETE: RequestHandler = async ({ request, locals: { supabase, safeGetSession } }) => {
	try {
		// Check authentication
		const { session, user } = await safeGetSession();
		if (!session || !user) {
			throw error(401, 'Not authenticated');
		}

		// Get current profile image URL
		const { data: currentProfile } = await supabase
			.from('profiles')
			.select('profile_image_url')
			.eq('id', user.id)
			.single();

		if (!currentProfile?.profile_image_url) {
			throw error(400, 'No profile picture to delete');
		}

		// Delete from Vercel Blob
		await del(currentProfile.profile_image_url, {
			token: BLOB_READ_WRITE_TOKEN
		});

		// Update profile to remove image URL
		const { error: updateError } = await supabase
			.from('profiles')
			.update({
				profile_image_url: null,
				updated_at: new Date().toISOString()
			})
			.eq('id', user.id);

		if (updateError) {
			throw error(500, 'Failed to update profile');
		}

		return json({
			success: true,
			message: 'Profile picture deleted successfully'
		});
	} catch (err) {
		console.error('Profile picture deletion error:', err);
		if (err instanceof Error && 'status' in err) {
			throw err; // Re-throw SvelteKit errors
		}
		throw error(500, 'Failed to delete profile picture');
	}
};