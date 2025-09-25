import { redirect, fail } from '@sveltejs/kit';

export const actions = {
	signup: async ({ request, locals: { supabase } }) => {
		const formData = await request.formData();
		const email = formData.get('email') as string;
		const password = formData.get('password') as string;
		const name = formData.get('name') as string;
		const dateOfBirth = formData.get('dateOfBirth') as string;

		// Basic validation
		if (!email || !password || !name) {
			return fail(400, {
				error: 'Email, password, and name are required',
				email,
				name
			});
		}

		// Sign up the user with metadata for profile creation
		const { data, error } = await supabase.auth.signUp({
			email,
			password,
			options: {
				data: {
					full_name: name,
					date_of_birth: dateOfBirth
				}
			}
		});

		if (error) {
			return fail(400, {
				error: error.message,
				email,
				name
			});
		}



		// If signup successful, redirect to confirmation or dashboard
		if (data.user && !data.user.email_confirmed_at) {
			redirect(303, '/auth/confirm?message=Check your email to confirm your account');
		} else {
			redirect(303, '/dashboard');
		}
	},

	login: async ({ request, locals: { supabase } }) => {
		const formData = await request.formData();
		const email = formData.get('email') as string;
		const password = formData.get('password') as string;

		// Basic validation
		if (!email || !password) {
			return fail(400, {
				error: 'Email and password are required',
				email
			});
		}

		const { data, error } = await supabase.auth.signInWithPassword({ email, password });

		if (error) {
			return fail(400, {
				error: error.message,
				email
			});
		}



		// Successful login - redirect to dashboard
		redirect(303, '/dashboard');
	},

	logout: async ({ locals: { supabase }, cookies }) => {
		try {
			await supabase.auth.signOut();
			// Clear all cookies to ensure complete logout
			cookies.getAll().forEach((cookie) => {
				cookies.delete(cookie.name, { path: '/' });
			});
			redirect(303, '/auth');
		} catch (err) {
			// Even if signOut fails, clear cookies and redirect
			cookies.getAll().forEach((cookie) => {
				cookies.delete(cookie.name, { path: '/' });
			});
			redirect(303, '/auth');
		}
	}
};
