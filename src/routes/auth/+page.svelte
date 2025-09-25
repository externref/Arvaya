<script lang="ts">
	import LoginSignup from '$lib/components/LoginSignup.svelte';
</script>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<div class="w-full max-w-md">
		<div class="mb-8 text-center">
			<h1 class="text-3xl font-bold text-foreground">Welcome to Arvaya</h1>
			<p class="mt-2 text-muted-foreground">Sign in to your account or create a new one</p>
		</div>

		<LoginSignup />
	</div>
</div>
