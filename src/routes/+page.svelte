<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Badge } from '$lib/components/ui/badge';
	import { ArrowRight, Map, Clock, Sparkles, Users, BookOpen, Globe, Zap } from 'lucide-svelte';
	import { page } from '$app/stores';
	import logo from '$lib/assets/branding/icon.png';

	let { data } = $props();
	let { session, user } = $derived(data);
</script>

<svelte:head>
	<title>Arvaya | Exploring India's Cultural Heritage and Traditions</title>
	<meta
		name="description"
		content="Interactive map and timeline to explore India's vast cultural heritage. Discover historical sites, art centers, and stories across space and time."
	/>
</svelte:head>

<div class="min-h-screen">
	<!-- Hero Section -->
	<section
		class="relative bg-gradient-to-br from-orange-50 via-yellow-50 to-red-50 px-4 py-20 dark:from-orange-950/20 dark:via-yellow-950/20 dark:to-red-950/20"
	>
		<div class="container mx-auto max-w-7xl">
			<div class="grid items-center gap-12 lg:grid-cols-2">
				<!-- Hero Content -->
				<div class="space-y-8">
					<div class="space-y-2">
						<Badge variant="secondary" class="mb-4">Smart India Hackathon 2025</Badge>
						<h1 class="text-4xl leading-tight font-bold text-foreground md:text-6xl">
							Exploring India's
							<span
								class="bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-transparent"
							>
								Cultural Heritage
							</span>
						</h1>
						<p class="max-w-lg text-xl text-muted-foreground">
							Interactive map and timeline to discover India's vast, distributed cultural legacy in
							one dynamic, visual platform.
						</p>
					</div>

					<div class="flex flex-col gap-4 sm:flex-row">
						{#if session && user}
							<Button
								href="/dashboard"
								size="lg"
								class="bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700"
							>
								<Map class="mr-2 h-4 w-4" />
								Go to Dashboard
								<ArrowRight class="ml-2 h-4 w-4" />
							</Button>
						{:else}
							<Button
								href="/auth"
								size="lg"
								class="bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700"
							>
								<Map class="mr-2 h-4 w-4" />
								Start Exploring
								<ArrowRight class="ml-2 h-4 w-4" />
							</Button>
						{/if}
						<Button variant="outline" size="lg">
							<BookOpen class="mr-2 h-4 w-4" />
							Learn More
						</Button>
					</div>

					<div class="flex items-center gap-8 text-sm text-muted-foreground">
						<div class="flex items-center gap-2">
							<div class="h-2 w-2 rounded-full bg-green-500"></div>
							<span>Interactive Experience</span>
						</div>
						<div class="flex items-center gap-2">
							<div class="h-2 w-2 rounded-full bg-blue-500"></div>
							<span>AI-Powered Discovery</span>
						</div>
						<div class="flex items-center gap-2">
							<div class="h-2 w-2 rounded-full bg-purple-500"></div>
							<span>Community Driven</span>
						</div>
					</div>
				</div>

				<!-- Hero Visual -->
				<div class="relative">
					<div
						class="relative rounded-3xl bg-gradient-to-br from-orange-100 to-red-100 p-4 shadow-2xl md:p-8 dark:from-orange-900/30 dark:to-red-900/30"
					>
						<div
							class="mb-4 flex flex-col items-center justify-center gap-3 sm:-ml-2 sm:flex-row sm:gap-6"
						>
							<img
								src={logo}
								alt="Arvaya Logo"
								class="h-20 w-20 drop-shadow-lg sm:h-28 sm:w-28 md:h-32 md:w-32"
							/>
							<div class="flex flex-col text-center sm:text-left">
								<h3
									class="font-samarkan bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-3xl leading-tight font-bold text-transparent sm:text-4xl md:text-6xl"
								>
									arvaya
								</h3>
								<p class="mt-1 text-sm text-muted-foreground sm:mt-2 sm:text-base md:text-lg">
									Discover, Learn, Share
								</p>
							</div>
						</div>

						<!-- Floating elements -->
						<div
							class="absolute -top-4 -right-4 rounded-full bg-orange-500 p-3 text-white shadow-lg"
						>
							<Globe class="h-6 w-6" />
						</div>
						<div
							class="absolute -bottom-4 -left-4 rounded-full bg-red-500 p-3 text-white shadow-lg"
						>
							<Clock class="h-6 w-6" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	<!-- Features Section -->
	<section class="px-4 py-20">
		<div class="container mx-auto max-w-7xl">
			<div class="mb-16 text-center">
				<h2 class="mb-4 text-3xl font-bold md:text-4xl">Proposed Solution</h2>
				<p class="mx-auto max-w-3xl text-xl text-muted-foreground">
					An innovative approach to centralizing and exploring India's rich cultural heritage
					through modern technology
				</p>
			</div>

			<div class="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
				<!-- Interactive Map Feature -->
				<Card.Root
					class="group border-2 transition-all duration-300 hover:border-orange-200 hover:shadow-xl"
				>
					<Card.Header>
						<div
							class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-orange-100 transition-transform group-hover:scale-110 dark:bg-orange-900/30"
						>
							<Map class="h-6 w-6 text-orange-600" />
						</div>
						<Card.Title>Interactive Map + Timeline</Card.Title>
						<Card.Description>
							Explore India's heritage across space and time with an intuitive map interface
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								Scroll through eras with key sites highlighted
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								Click markers for historical data & visuals
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								3D views and immersive experiences
							</li>
						</ul>
					</Card.Content>
				</Card.Root>

				<!-- AI Recommendations -->
				<Card.Root
					class="group border-2 transition-all duration-300 hover:border-blue-200 hover:shadow-xl"
				>
					<Card.Header>
						<div
							class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100 transition-transform group-hover:scale-110 dark:bg-blue-900/30"
						>
							<Sparkles class="h-6 w-6 text-blue-600" />
						</div>
						<Card.Title>AI-Powered Recommendations</Card.Title>
						<Card.Description>
							Personalized discovery based on your interests and learning preferences
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Smart content suggestions
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Adaptive learning paths
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Cultural connection insights
							</li>
						</ul>
					</Card.Content>
				</Card.Root>

				<!-- Community Features -->
				<Card.Root
					class="group border-2 transition-all duration-300 hover:border-purple-200 hover:shadow-xl"
				>
					<Card.Header>
						<div
							class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100 transition-transform group-hover:scale-110 dark:bg-purple-900/30"
						>
							<Users class="h-6 w-6 text-purple-600" />
						</div>
						<Card.Title>Community Engagement</Card.Title>
						<Card.Description>
							Empower users to contribute stories, insights, and preserve cultural knowledge
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Share cultural stories & insights
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Digital preservation efforts
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Collaborative storytelling
							</li>
						</ul>
					</Card.Content>
				</Card.Root>
			</div>
		</div>
	</section>

	<!-- Problem & Solution Section -->
	<section class="bg-muted/50 px-4 py-20">
		<div class="container mx-auto max-w-7xl">
			<div class="grid gap-16 lg:grid-cols-2">
				<!-- Problem -->
				<div class="space-y-6">
					<h2 class="text-3xl font-bold text-red-600">Addressing Problem</h2>
					<div class="space-y-4">
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-red-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Centralized Cultural Legacy</h3>
								<p class="text-muted-foreground">
									India's vast, distributed cultural heritage needs a unified, dynamic visual
									platform for easy exploration.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-red-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Timeline Perspective</h3>
								<p class="text-muted-foreground">
									Need for easy grasp of history & evolution through interactive timeline views.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-red-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Engaging Learning</h3>
								<p class="text-muted-foreground">
									Transform passive learning into engaging experiences via multimedia, 3D, and AI
									suggestions.
								</p>
							</div>
						</div>
					</div>
				</div>

				<!-- Innovation -->
				<div class="space-y-6">
					<h2 class="text-3xl font-bold text-green-600">Innovation & Uniqueness</h2>
					<div class="space-y-4">
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-green-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Space-Time Exploration</h3>
								<p class="text-muted-foreground">
									Interactive map with timeline - explore India's heritage across both space and
									time dimensions.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-green-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Community Empowerment</h3>
								<p class="text-muted-foreground">
									Enable community blogging for sharing stories & insights, not just passive
									viewing.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-green-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Digital Preservation</h3>
								<p class="text-muted-foreground">
									Participate in digital preservation and storytelling, creating a living heritage
									archive.
								</p>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	<!-- CTA Section -->
	<section class="bg-gradient-to-r from-orange-600 to-red-600 px-4 py-20 text-white">
		<div class="container mx-auto max-w-4xl text-center">
			<div class="space-y-8">
				<div class="space-y-4">
					<h2 class="text-3xl font-bold md:text-4xl">Ready to Explore India's Heritage?</h2>
					<p class="mx-auto max-w-2xl text-xl opacity-90">
						Join thousands of heritage enthusiasts in discovering, learning, and preserving India's
						rich cultural legacy.
					</p>
				</div>

				<div class="flex flex-col justify-center gap-4 sm:flex-row">
					{#if session && user}
						<Button
							size="lg"
							variant="secondary"
							class="bg-white text-orange-600 hover:bg-orange-50"
						>
							<Map class="mr-2 h-4 w-4" />
							Explore Heritage Map
							<ArrowRight class="ml-2 h-4 w-4" />
						</Button>
						<Button size="lg" variant="outline" class="border-white text-white hover:bg-white/10">
							<Users class="mr-2 h-4 w-4" />
							Join Community
						</Button>
					{:else}
						<Button
							href="/auth"
							size="lg"
							variant="secondary"
							class="bg-white text-orange-600 hover:bg-orange-50"
						>
							<Zap class="mr-2 h-4 w-4" />
							Get Started Free
							<ArrowRight class="ml-2 h-4 w-4" />
						</Button>
						<Button size="lg" variant="outline" class="border-white text-white hover:bg-white/10">
							<BookOpen class="mr-2 h-4 w-4" />
							Learn More
						</Button>
					{/if}
				</div>

				<p class="text-sm opacity-75">
					Part of Smart India Hackathon 2025 • Preserving Heritage Through Technology
				</p>
			</div>
		</div>
	</section>
</div>
