<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import * as Card from '$lib/components/ui/card';
	import * as Tabs from '$lib/components/ui/tabs';
	import { fade, slide } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { enhance } from '$app/forms';

	let transition = false;

	onMount(() => {
		transition = true;
	});

	// Login form data
	let loginData = {
		email: '',
		password: ''
	};

	// Signup form data
	let signupData = {
		name: '',
		email: '',
		dateOfBirth: '',
		password: ''
	};

	// Password validation
	let passwordErrors: string[] = [];
	let isPasswordValid = false;

	function validatePassword(password: string) {
		passwordErrors = [];

		if (password.length < 8) {
			passwordErrors.push('At least 8 characters');
		}
		if (!/[A-Z]/.test(password)) {
			passwordErrors.push('One uppercase letter');
		}
		if (!/[a-z]/.test(password)) {
			passwordErrors.push('One lowercase letter');
		}
		if (!/[0-9]/.test(password)) {
			passwordErrors.push('One number');
		}
		if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
			passwordErrors.push('One special character');
		}

		isPasswordValid = passwordErrors.length === 0;
		return isPasswordValid;
	}

	// Reactive statement to validate password when it changes
	$: if (signupData.password) {
		validatePassword(signupData.password);
	}

	// Form state management
	let isLoading = false;
	let errorMessage = '';
	let showForgotPassword = false;
	let forgotPasswordEmail = '';
	let forgotPasswordMessage = '';
	let forgotPasswordError = '';

	// Form handlers - these will be replaced by form actions
	function handleLoginSubmit() {
		// This function will be handled by the form action
		isLoading = true;
		errorMessage = '';
	}

	function handleSignupSubmit() {
		if (!isPasswordValid) {
			errorMessage = 'Please fix password requirements before submitting';
			return false;
		}
		isLoading = true;
		errorMessage = '';
		return true;
	}

	function handleForgotPasswordSubmit() {
		isLoading = true;
		forgotPasswordError = '';
		forgotPasswordMessage = '';
	}
</script>

{#if transition}
	<div transition:fade={{ duration: 300 }} class="w-full max-w-md">
		<Tabs.Root value="login" class="w-full">
			<Tabs.List class="grid w-full grid-cols-2">
				<Tabs.Trigger value="login">Login</Tabs.Trigger>
				<Tabs.Trigger value="signup">Sign Up</Tabs.Trigger>
			</Tabs.List>

			<!-- Login Tab -->
			<Tabs.Content value="login">
				<div in:fade={{ duration: 300, delay: 100 }} out:fade={{ duration: 200 }}>
					<Card.Root>
						<Card.Header>
							<Card.Title>Welcome Back</Card.Title>
							<Card.Description>Enter your credentials to access your account</Card.Description>
						</Card.Header>
						<Card.Content class="space-y-4">
							{#if errorMessage}
								<div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
									{errorMessage}
								</div>
							{/if}
							<form
								method="POST"
								action="?/login"
								use:enhance={() => {
									handleLoginSubmit();
									return async ({ result, update }) => {
										isLoading = false;
										// Only show errors for actual failures, not redirects or success
										if (result.type === 'failure' && result.data?.error) {
											// @ts-ignore
											errorMessage = result.data.error;
										} else {
											// Clear error message for success, redirect, or any other case
											errorMessage = '';
										}
										await update();
									};
								}}
								class="space-y-4"
							>
								<div class="space-y-2">
									<Label for="login-email">Email</Label>
									<Input
										id="login-email"
										name="email"
										type="email"
										placeholder="Enter your email"
										bind:value={loginData.email}
										disabled={isLoading}
										required
									/>
								</div>
								<div class="space-y-2">
									<Label for="login-password">Password</Label>
									<Input
										id="login-password"
										name="password"
										type="password"
										placeholder="Enter your password"
										bind:value={loginData.password}
										disabled={isLoading}
										required
									/>
								</div>
								<Button type="submit" class="w-full" disabled={isLoading}>
									{isLoading ? 'Signing In...' : 'Sign In'}
								</Button>
							</form>
							
							<!-- Forgot Password Link -->
							<div class="text-center">
								<button
									type="button"
									class="text-sm text-blue-600 hover:text-blue-800 underline"
									onclick={() => (showForgotPassword = true)}
								>
									Forgot your password?
								</button>
							</div>
						</Card.Content>
					</Card.Root>
				</div>
			</Tabs.Content>

			<!-- Signup Tab -->
			<Tabs.Content value="signup">
				<div in:fade={{ duration: 300, delay: 100 }} out:fade={{ duration: 200 }}>
					<Card.Root>
						<Card.Header>
							<Card.Title>Create Account</Card.Title>
							<Card.Description>
								Fill in the information below to create your account
							</Card.Description>
						</Card.Header>
						<Card.Content class="space-y-4">
							{#if errorMessage}
								<div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
									{errorMessage}
								</div>
							{/if}
							<form
								method="POST"
								action="?/signup"
								use:enhance={() => {
									return async ({ result, update }) => {
										if (!handleSignupSubmit()) {
											return;
										}
										isLoading = false;
										// Only show errors for actual failures, not redirects or success
										if (result.type === 'failure' && result.data?.error) {
											// @ts-ignore
											errorMessage = result.data.error;
										} else {
											// Clear error message for success, redirect, or any other case
											errorMessage = '';
										}
										await update();
									};
								}}
								class="space-y-4"
							>
								<div class="space-y-2">
									<Label for="signup-name">Full Name</Label>
									<Input
										id="signup-name"
										name="name"
										type="text"
										placeholder="Enter your full name"
										bind:value={signupData.name}
										disabled={isLoading}
										required
									/>
								</div>
								<div class="space-y-2">
									<Label for="signup-email">Email</Label>
									<Input
										id="signup-email"
										name="email"
										type="email"
										placeholder="Enter your email"
										bind:value={signupData.email}
										disabled={isLoading}
										required
									/>
								</div>
								<div class="space-y-2">
									<Label for="signup-dob">Date of Birth</Label>
									<Input
										id="signup-dob"
										name="dateOfBirth"
										type="date"
										bind:value={signupData.dateOfBirth}
										disabled={isLoading}
										required
									/>
								</div>
								<div class="space-y-2">
									<Label for="signup-password">Password</Label>
									<Input
										id="signup-password"
										name="password"
										type="password"
										placeholder="Create a password"
										bind:value={signupData.password}
										class={signupData.password && !isPasswordValid ? 'border-red-500' : ''}
										disabled={isLoading}
										required
									/>
									{#if signupData.password && passwordErrors.length > 0}
										<div
											class="space-y-1 text-sm text-red-600"
											in:slide={{ duration: 300 }}
											out:slide={{ duration: 200 }}
										>
											<p class="font-medium">Password must contain:</p>
											<ul class="list-inside list-disc space-y-1">
												{#each passwordErrors as error}
													<li>{error}</li>
												{/each}
											</ul>
										</div>
									{:else if signupData.password && isPasswordValid}
										<div
											class="text-sm font-medium text-green-600"
											in:slide={{ duration: 300 }}
											out:slide={{ duration: 200 }}
										>
											✓ Password meets all requirements
										</div>
									{/if}
								</div>
								<Button
									type="submit"
									class="w-full"
									disabled={isLoading || (signupData.password ? !isPasswordValid : false)}
								>
									{isLoading ? 'Creating Account...' : 'Create Account'}
								</Button>
							</form>
						</Card.Content>
					</Card.Root>
				</div>
			</Tabs.Content>
		</Tabs.Root>

		<!-- Forgot Password Modal -->
		{#if showForgotPassword}
			<div
				class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
				onclick={(e) => e.target === e.currentTarget && (showForgotPassword = false)}
				transition:fade={{ duration: 200 }}
			>
				<div class="bg-background rounded-lg p-6 w-full max-w-md" transition:slide={{ duration: 300 }}>
					<div class="mb-4">
						<h3 class="text-lg font-semibold">Reset Password</h3>
						<p class="text-sm text-muted-foreground">
							Enter your email address and we'll send you a link to reset your password.
						</p>
					</div>

					{#if forgotPasswordMessage}
						<div class="mb-4 rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-600">
							{forgotPasswordMessage}
						</div>
					{/if}

					{#if forgotPasswordError}
						<div class="mb-4 rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
							{forgotPasswordError}
						</div>
					{/if}

					<form
						method="POST"
						action="?/resetPassword"
						use:enhance={() => {
							handleForgotPasswordSubmit();
							return async ({ result, update }) => {
								isLoading = false;
								if (result.type === 'success' && result.data?.success) {
									// @ts-ignore
									forgotPasswordMessage = result.data.message;
									forgotPasswordError = '';
									forgotPasswordEmail = '';
								} else if (result.type === 'failure' && result.data?.error) {
									// @ts-ignore
									forgotPasswordError = result.data.error;
									forgotPasswordMessage = '';
								}
								await update();
							};
						}}
						class="space-y-4"
					>
						<div class="space-y-2">
							<Label for="forgot-password-email">Email</Label>
							<Input
								id="forgot-password-email"
								name="email"
								type="email"
								placeholder="Enter your email"
								bind:value={forgotPasswordEmail}
								disabled={isLoading}
								required
							/>
						</div>

						<div class="flex gap-2">
							<Button
								type="button"
								variant="outline"
								class="flex-1"
								onclick={() => (showForgotPassword = false)}
								disabled={isLoading}
							>
								Cancel
							</Button>
							<Button type="submit" class="flex-1" disabled={isLoading}>
								{isLoading ? 'Sending...' : 'Send Reset Link'}
							</Button>
						</div>
					</form>
				</div>
			</div>
		{/if}
	</div>
{/if}
