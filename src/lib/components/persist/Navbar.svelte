<script lang="ts">
	import * as NavigationMenu from '$lib/components/ui/navigation-menu';
	import ToggleTheme from '$lib/components/persist/ToggleTheme.svelte';
	import { Button } from '$lib/components/ui/button';
	import Icon from '$lib/assets/branding/icon.png';
	import { page } from '$app/stores';
	import { enhance } from '$app/forms';
	import { createAvatarProps } from '$lib/utils/avatar';

	let { session, user, profile } = $derived($page.data);
	let mobileMenuOpen = $state(false);
	
	// Create avatar properties for navbar
	const navAvatarProps = $derived(
		session && (profile || user) 
			? createAvatarProps(profile || user, 'h-8 w-8')
			: null
	);

	function toggleMobileMenu() {
		mobileMenuOpen = !mobileMenuOpen;
	}

	function closeMobileMenu() {
		mobileMenuOpen = false;
	}
</script>

<nav class="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
	<div class="container mx-auto px-4">
		<div class="flex h-16 items-center justify-between">
			<!-- Website Logo/Name -->
			<div class="flex items-center">
				<a
					href="/"
					class="font-samarkan flex items-center space-x-2 text-4xl text-branding transition-colors hover:text-foreground/80"
					onclick={closeMobileMenu}
				>
					<img src={Icon} alt="Arvaya Logo" class="h-8 w-8" />
					<span class="hidden sm:inline">arvaya</span>
				</a>
			</div>

			<!-- Desktop Navigation Menu -->
			<NavigationMenu.Root class="hidden md:flex">
				<NavigationMenu.List>
					<!-- Navigation items can be added here if needed -->
				</NavigationMenu.List>
			</NavigationMenu.Root>

			<!-- Desktop Right side actions -->
			<div class="hidden md:flex items-center space-x-2">
				{#if session && user}
					<!-- Authenticated user menu -->
					{#if navAvatarProps}
						<img 
							{...navAvatarProps}
							loading="lazy"
						/>
					{/if}
					<span class="text-sm text-muted-foreground hidden lg:inline">
						Welcome, {user.user_metadata?.full_name || user.email}
					</span>
					{#if profile?.username}
						<Button href="/profile/{profile.username}" variant="ghost" size="sm" class="h-9 px-3">
							My Profile
						</Button>
					{/if}
					<Button href="/dashboard" variant="ghost" size="sm" class="h-9 px-3">Dashboard</Button>
					<form method="POST" action="/auth?/logout" use:enhance>
						<Button type="submit" variant="outline" size="sm" class="h-9 px-3">Sign Out</Button>
					</form>
				{:else}
					<!-- Guest user actions -->
					<Button href="/auth" variant="outline" size="sm" class="h-9 px-3">Sign In</Button>
				{/if}
				<ToggleTheme />
			</div>

			<!-- Mobile menu button -->
			<div class="flex md:hidden items-center space-x-2">
				<ToggleTheme />
				<button
					onclick={toggleMobileMenu}
					class="inline-flex items-center justify-center rounded-md p-2 text-foreground hover:bg-accent hover:text-accent-foreground focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary"
					aria-expanded={mobileMenuOpen}
					aria-label="Toggle menu"
				>
					<span class="sr-only">Open main menu</span>
					{#if mobileMenuOpen}
						<!-- X icon -->
						<svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
						</svg>
					{:else}
						<!-- Hamburger icon -->
						<svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
						</svg>
					{/if}
				</button>
			</div>
		</div>

		<!-- Mobile menu -->
		{#if mobileMenuOpen}
			<div class="md:hidden border-t bg-background">
				<div class="px-2 pt-2 pb-3 space-y-1">
					{#if session && user}
						<!-- Mobile authenticated user menu -->
						<div class="px-3 py-2 flex items-center gap-3">
							{#if navAvatarProps}
								<img 
									{...navAvatarProps}
									loading="lazy"
								/>
							{/if}
							<div>
								<div class="text-base font-medium text-foreground">
									{user.user_metadata?.full_name || user.email}
								</div>
								<div class="text-sm text-muted-foreground">
									{user.email}
								</div>
							</div>
						</div>
						
						{#if profile?.username}
							<a
								href="/profile/{profile.username}"
								class="block px-3 py-2 rounded-md text-base font-medium text-foreground hover:bg-accent hover:text-accent-foreground"
								onclick={closeMobileMenu}
							>
								My Profile
							</a>
						{/if}
						
						<a
							href="/dashboard"
							class="block px-3 py-2 rounded-md text-base font-medium text-foreground hover:bg-accent hover:text-accent-foreground"
							onclick={closeMobileMenu}
						>
							Dashboard
						</a>
						
						<form method="POST" action="/auth?/logout" use:enhance class="px-3 py-2">
							<Button 
								type="submit" 
								variant="outline" 
								size="sm" 
								class="w-full justify-start h-10"
								onclick={closeMobileMenu}
							>
								Sign Out
							</Button>
						</form>
					{:else}
						<!-- Mobile guest user actions -->
						<div class="px-3 py-2">
							<Button 
								href="/auth" 
								variant="outline" 
								size="sm" 
								class="w-full justify-center h-10"
								onclick={closeMobileMenu}
							>
								Sign In
							</Button>
						</div>
					{/if}
				</div>
			</div>
		{/if}
	</div>
</nav>
