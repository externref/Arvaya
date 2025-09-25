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
						<Badge variant="secondary" class="mb-4">🏛️ Heritage Explorer</Badge>
						<h1 class="text-4xl leading-tight font-bold text-foreground md:text-6xl">
							Discover India's
							<span
								class="bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-transparent"
							>
								Cultural Heritage
							</span>
						</h1>
						<p class="max-w-lg text-xl text-muted-foreground">
							Journey through centuries of rich cultural traditions, historical monuments, and living heritage sites across the Indian subcontinent.
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
							<span>Expert Curated</span>
						</div>
						<div class="flex items-center gap-2">
							<div class="h-2 w-2 rounded-full bg-blue-500"></div>
							<span>Immersive Learning</span>
						</div>
						<div class="flex items-center gap-2">
							<div class="h-2 w-2 rounded-full bg-purple-500"></div>
							<span>Cultural Preservation</span>
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
				<h2 class="mb-4 text-3xl font-bold md:text-4xl">Explore Heritage Like Never Before</h2>
				<p class="mx-auto max-w-3xl text-xl text-muted-foreground">
					Experience India's rich cultural tapestry through immersive digital experiences, connecting past and present in meaningful ways
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
						<Card.Title>Heritage Mapping</Card.Title>
						<Card.Description>
							Navigate through India's cultural landscape with our comprehensive heritage mapping system
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								Explore UNESCO World Heritage Sites
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								Discover hidden architectural gems
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-orange-500"></div>
								Virtual tours and 360° experiences
							</li>
						</ul>
					</Card.Content>
				</Card.Root>

				<!-- Personalized Discovery -->
				<Card.Root
					class="group border-2 transition-all duration-300 hover:border-blue-200 hover:shadow-xl"
				>
					<Card.Header>
						<div
							class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100 transition-transform group-hover:scale-110 dark:bg-blue-900/30"
						>
							<Sparkles class="h-6 w-6 text-blue-600" />
						</div>
						<Card.Title>Personalized Discovery</Card.Title>
						<Card.Description>
							Curated heritage experiences tailored to your cultural interests and preferences
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Curated heritage collections
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Customized cultural journeys
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
								Expert-guided cultural insights
							</li>
						</ul>
					</Card.Content>
				</Card.Root>

				<!-- Heritage Community -->
				<Card.Root
					class="group border-2 transition-all duration-300 hover:border-purple-200 hover:shadow-xl"
				>
					<Card.Header>
						<div
							class="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100 transition-transform group-hover:scale-110 dark:bg-purple-900/30"
						>
							<Users class="h-6 w-6 text-purple-600" />
						</div>
						<Card.Title>Heritage Community</Card.Title>
						<Card.Description>
							Connect with fellow heritage enthusiasts, scholars, and cultural preservationists
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<ul class="space-y-2 text-sm text-muted-foreground">
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Connect with heritage experts
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Share cultural discoveries
							</li>
							<li class="flex items-center gap-2">
								<div class="h-1.5 w-1.5 rounded-full bg-purple-500"></div>
								Preserve family heritage stories
							</li>
						</ul>
					</Card.Content>
				</Card.Root>
			</div>
		</div>
	</section>

	<!-- Why Choose Arvaya Section -->
	<section class="bg-muted/50 px-4 py-20">
		<div class="container mx-auto max-w-7xl">
			<div class="grid gap-16 lg:grid-cols-2">
				<!-- Mission -->
				<div class="space-y-6">
					<h2 class="text-3xl font-bold text-orange-600">Our Mission</h2>
					<div class="space-y-4">
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-orange-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Preserve Cultural Legacy</h3>
								<p class="text-muted-foreground">
									Safeguarding India's rich cultural heritage for future generations through digital preservation and storytelling.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-orange-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Educational Impact</h3>
								<p class="text-muted-foreground">
									Making heritage education accessible, engaging, and meaningful for learners of all ages and backgrounds.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-orange-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Cultural Connection</h3>
								<p class="text-muted-foreground">
									Bridging the gap between past and present, helping people connect with their cultural roots.
								</p>
							</div>
						</div>
					</div>
				</div>

				<!-- What Makes Us Different -->
				<div class="space-y-6">
					<h2 class="text-3xl font-bold text-blue-600">What Makes Us Different</h2>
					<div class="space-y-4">
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-blue-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Immersive Experiences</h3>
								<p class="text-muted-foreground">
									Virtual reality tours, 3D reconstructions, and interactive timelines bring heritage sites to life.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-blue-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Expert Curation</h3>
								<p class="text-muted-foreground">
									Content curated by historians, archaeologists, and cultural experts ensuring accuracy and depth.
								</p>
							</div>
						</div>
						<div class="flex gap-4">
							<div class="mt-2 h-2 w-2 flex-shrink-0 rounded-full bg-blue-500"></div>
							<div>
								<h3 class="mb-2 font-semibold">Living Heritage</h3>
								<p class="text-muted-foreground">
									Dynamic platform where heritage lives and grows through community contributions and discoveries.
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
					<h2 class="text-3xl font-bold md:text-4xl">Begin Your Cultural Journey Today</h2>
					<p class="mx-auto max-w-2xl text-xl opacity-90">
						Join a growing community of heritage enthusiasts, scholars, and cultural explorers in preserving and celebrating India's incredible legacy.
					</p>
				</div>

				<div class="flex flex-col justify-center gap-4 sm:flex-row">
					{#if session && user}
						<Button
							href="/dashboard"
							size="lg"
							variant="secondary"
							class="bg-white text-orange-600 hover:bg-orange-50"
						>
							<Map class="mr-2 h-4 w-4" />
							Explore Heritage
							<ArrowRight class="ml-2 h-4 w-4" />
						</Button>
						<Button size="lg" variant="outline" class="border-white text-white hover:bg-white/10">
							<Users class="mr-2 h-4 w-4" />
							Connect with Community
						</Button>
					{:else}
						<Button
							href="/auth"
							size="lg"
							variant="secondary"
							class="bg-white text-orange-600 hover:bg-orange-50"
						>
							<Zap class="mr-2 h-4 w-4" />
							Start Exploring
							<ArrowRight class="ml-2 h-4 w-4" />
						</Button>
						<Button size="lg" variant="outline" class="border-white text-white hover:bg-white/10">
							<BookOpen class="mr-2 h-4 w-4" />
							Discover More
						</Button>
					{/if}
				</div>

				<p class="text-sm opacity-75">
					Trusted by heritage enthusiasts • Powered by cultural experts • Built for preservation
				</p>
			</div>
		</div>
	</section>
</div>
