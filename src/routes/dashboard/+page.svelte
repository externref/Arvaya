<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Badge } from '$lib/components/ui/badge';
	import {
		Map,
		Clock,
		BookOpen,
		Users,
		Sparkles,
		Settings,
		Globe,
		PenTool,
		UserCog
	} from 'lucide-svelte';

	let { data } = $props();
	let { session, user } = $derived(data);
</script>

<svelte:head>
	<title>Dashboard | Arvaya</title>
	<meta
		name="description"
		content="Your personal Arvaya dashboard to explore India's cultural heritage."
	/>
</svelte:head>

<div class="min-h-screen bg-background">
	<div class="container mx-auto max-w-7xl px-4 py-8">
		<!-- Welcome Header -->
		<div class="mb-8">
			<h1 class="mb-2 text-3xl font-bold text-foreground md:text-4xl">
				Welcome back, {user?.user_metadata?.full_name || 'Explorer'}! 👋
			</h1>
			<p class="text-lg text-muted-foreground">
				Continue your journey through India's rich cultural heritage
			</p>
		</div>

		<!-- Quick Options -->
		<div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
			<Card.Root
				class="cursor-pointer border-2 transition-all duration-200 hover:scale-105 hover:border-orange-200 hover:shadow-lg dark:hover:border-orange-800"
			>
				<Card.Content class="p-4">
					<div class="flex flex-col items-center space-y-2 text-center">
						<div class="rounded-full bg-orange-100 p-3 dark:bg-orange-900/30">
							<Map class="h-6 w-6 text-orange-600 dark:text-orange-400" />
						</div>
						<div>
							<h3 class="mb-0.5 text-base font-semibold">Explore Map</h3>
							<p class="text-xs text-muted-foreground">Discover heritage sites across India</p>
						</div>
					</div>
				</Card.Content>
			</Card.Root>

			<Card.Root
				class="cursor-pointer border-2 transition-all duration-200 hover:scale-105 hover:border-blue-200 hover:shadow-lg dark:hover:border-blue-800"
			>
				<Card.Content class="p-4">
					<div class="flex flex-col items-center space-y-2 text-center">
						<div class="rounded-full bg-blue-100 p-3 dark:bg-blue-900/30">
							<Globe class="h-6 w-6 text-blue-600 dark:text-blue-400" />
						</div>
						<div>
							<h3 class="mb-0.5 text-base font-semibold">Discover</h3>
							<p class="text-xs text-muted-foreground">Explore new cultures and traditions</p>
						</div>
					</div>
				</Card.Content>
			</Card.Root>

			<Card.Root
				class="cursor-pointer border-2 transition-all duration-200 hover:scale-105 hover:border-green-200 hover:shadow-lg dark:hover:border-green-800"
			>
				<Card.Content class="p-4">
					<div class="flex flex-col items-center space-y-2 text-center">
						<div class="rounded-full bg-green-100 p-3 dark:bg-green-900/30">
							<PenTool class="h-6 w-6 text-green-600 dark:text-green-400" />
						</div>
						<div>
							<h3 class="mb-0.5 text-base font-semibold">Blogs</h3>
							<p class="text-xs text-muted-foreground">Read stories and insights</p>
						</div>
					</div>
				</Card.Content>
			</Card.Root>

			<a href="/me" class="block">
				<Card.Root
					class="cursor-pointer border-2 transition-all duration-200 hover:scale-105 hover:border-purple-200 hover:shadow-lg dark:hover:border-purple-800"
				>
					<Card.Content class="p-4">
						<div class="flex flex-col items-center space-y-2 text-center">
							<div class="rounded-full bg-purple-100 p-3 dark:bg-purple-900/30">
								<UserCog class="h-6 w-6 text-purple-600 dark:text-purple-400" />
							</div>
							<div>
								<h3 class="mb-0.5 text-base font-semibold">Customise Profile</h3>
								<p class="text-xs text-muted-foreground">Personalize your experience</p>
							</div>
						</div>
					</Card.Content>
				</Card.Root>
			</a>
		</div>
	</div>
</div>
