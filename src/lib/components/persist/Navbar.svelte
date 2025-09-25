<script lang="ts">
	import * as NavigationMenu from '$lib/components/ui/navigation-menu';
	import ToggleTheme from '$lib/components/persist/ToggleTheme.svelte';
	import { Button } from '$lib/components/ui/button';
	import Icon from '$lib/assets/branding/icon.png';
	import { page } from '$app/stores';
	import { enhance } from '$app/forms';

	let { session, user } = $derived($page.data);
</script>

<nav class="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
	<div class="container mx-auto px-4">
		<div class="flex h-16 items-center justify-between">
			<!-- Website Logo/Name -->
			<div class="flex items-center">
				<a
					href="/"
					class="font-samarkan flex items-center space-x-2 text-4xl text-branding transition-colors hover:text-foreground/80"
				>
					<img src={Icon} alt="Arvaya Logo" class="h-8 w-8" />
					<span>arvaya</span>
				</a>
			</div>

			<!-- Navigation Menu -->
			<NavigationMenu.Root class="hidden md:flex">
				<NavigationMenu.List>
					<!-- Navigation items can be added here if needed -->
				</NavigationMenu.List>
			</NavigationMenu.Root>

			<!-- Right side actions -->
			<div class="flex items-center space-x-2">
				{#if session && user}
					<!-- Authenticated user menu -->
					<span class="text-sm text-muted-foreground">
						Welcome, {user.user_metadata?.full_name || user.email}
					</span>
					<form method="POST" action="/auth?/logout" use:enhance>
						<Button type="submit" variant="outline" size="sm" class="h-9 px-3">Sign Out</Button>
					</form>
				{:else}
					<!-- Guest user actions -->
					<Button href="/auth" variant="outline" size="sm" class="h-9 px-3">Sign In</Button>
				{/if}
				<ToggleTheme />
			</div>
		</div>
	</div>
</nav>
