import { redirect, fail } from '@sveltejs/kit';

export const actions = {
	updatePassword: async ({ request, locals: { supabase }, url }) => {
		const formData = await request.formData();
		const password = formData.get('password') as string;
		const confirmPassword = formData.get('confirmPassword') as string;

		// Basic validation
		if (!password || !confirmPassword) {
			return fail(400, {
				error: 'Both password fields are required'
			});
		}

		if (password !== confirmPassword) {
			return fail(400, {
				error: 'Passwords do not match'
			});
		}

		// Validate password strength
		if (password.length < 8) {
			return fail(400, {
				error: 'Password must be at least 8 characters long'
			});
		}

		// Check if user is authenticated (they should be after clicking the reset link)
		const { data: { user }, error: userError } = await supabase.auth.getUser();

		if (userError || !user) {
			return fail(400, {
				error: 'Invalid or expired reset link. Please request a new password reset.'
			});
		}

		// Update the password
		const { error } = await supabase.auth.updateUser({
			password: password
		});

		if (error) {
			return fail(400, {
				error: error.message
			});
		}

		return {
			success: true,
			message: 'Password updated successfully! You can now sign in with your new password.'
		};
	}
};