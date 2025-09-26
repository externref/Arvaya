<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import * as Card from '$lib/components/ui/card';
	import { enhance } from '$app/forms';
	import { page } from '$app/stores';

	let { form } = $props();

	// Password validation
	let password = $state('');
	let confirmPassword = $state('');
	let passwordErrors = $state<string[]>([]);
	let isPasswordValid = $state(false);
	let isLoading = $state(false);
	let errorMessage = $state('');

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
	$effect(() => {
		if (password) {
			validatePassword(password);
		}
	});

	let passwordsMatch = $derived(password && confirmPassword && password === confirmPassword);
	let canSubmit = $derived(isPasswordValid && passwordsMatch);

	function handleSubmit() {
		if (!canSubmit) {
			errorMessage = 'Please fix all validation errors before submitting';
			return false;
		}
		isLoading = true;
		errorMessage = '';
		return true;
	}
</script>

<svelte:head>
	<title>Reset Password | Arvaya</title>
	<meta name="description" content="Reset your Arvaya account password." />
</svelte:head>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<div class="w-full max-w-md">
		<div class="mb-8 text-center">
			<h1 class="text-3xl font-bold text-foreground">Reset Password</h1>
			<p class="mt-2 text-muted-foreground">Enter your new password below</p>
		</div>

		<Card.Root>
			<Card.Header>
				<Card.Title>Create New Password</Card.Title>
				<Card.Description>
					Choose a strong password for your account
				</Card.Description>
			</Card.Header>
			<Card.Content class="space-y-4">
				{#if form?.error}
					<div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
						{form.error}
					</div>
				{/if}

				{#if form?.success}
					<div class="rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-600">
						{form.message}
					</div>
				{:else}
					<form
						method="POST"
						action="?/updatePassword"
						use:enhance={() => {
							return async ({ result, update }) => {
								if (!handleSubmit()) {
									return;
								}
								isLoading = false;
								await update();
							};
						}}
						class="space-y-4"
					>
						<div class="space-y-2">
							<Label for="password">New Password</Label>
							<Input
								id="password"
								name="password"
								type="password"
								placeholder="Enter your new password"
								bind:value={password}
								disabled={isLoading}
								required
							/>
						</div>

						<div class="space-y-2">
							<Label for="confirmPassword">Confirm Password</Label>
							<Input
								id="confirmPassword"
								name="confirmPassword"
								type="password"
								placeholder="Confirm your new password"
								bind:value={confirmPassword}
								disabled={isLoading}
								required
							/>
						</div>

						<!-- Password validation feedback -->
						{#if password && passwordErrors.length > 0}
							<div class="rounded-md border border-orange-200 bg-orange-50 p-3 text-sm text-orange-600">
								<p class="font-medium">Password must contain:</p>
								<ul class="list-inside list-disc space-y-1">
									{#each passwordErrors as error}
										<li>{error}</li>
									{/each}
								</ul>
							</div>
						{:else if password && isPasswordValid}
							<div class="rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-600">
								✓ Password meets all requirements
							</div>
						{/if}

						<!-- Password match validation -->
						{#if confirmPassword && password !== confirmPassword}
							<div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
								Passwords do not match
							</div>
						{:else if confirmPassword && passwordsMatch}
							<div class="rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-600">
								✓ Passwords match
							</div>
						{/if}

						{#if errorMessage}
							<div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-600">
								{errorMessage}
							</div>
						{/if}

						<Button 
							type="submit" 
							class="w-full" 
							disabled={isLoading || !canSubmit}
						>
							{isLoading ? 'Updating Password...' : 'Update Password'}
						</Button>
					</form>
				{/if}

				<div class="text-center">
					<a href="/auth" class="text-sm text-blue-600 hover:text-blue-800 underline">
						Back to Login
					</a>
				</div>
			</Card.Content>
		</Card.Root>
	</div>
</div>