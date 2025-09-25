<script lang="ts">
	import { page } from '$app/stores';
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';

	const message =
		$page.url.searchParams.get('message') || 'Please check your email to confirm your account.';
</script>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<div class="w-full max-w-md">
		<Card.Root>
			<Card.Header>
				<Card.Title>Check Your Email</Card.Title>
				<Card.Description>We've sent you a confirmation link</Card.Description>
			</Card.Header>
			<Card.Content class="space-y-4">
				<div class="space-y-4 text-center">
					<div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-blue-100">
						<svg
							class="h-8 w-8 text-blue-600"
							fill="none"
							stroke="currentColor"
							viewBox="0 0 24 24"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
							></path>
						</svg>
					</div>
					<p class="text-sm text-muted-foreground">
						{message}
					</p>
					<p class="text-xs text-muted-foreground">
						Didn't receive the email? Check your spam folder or contact support.
					</p>
				</div>
			</Card.Content>
			<Card.Footer>
				<Button href="/auth" class="w-full" variant="outline">Back to Login</Button>
			</Card.Footer>
		</Card.Root>
	</div>
</div>
