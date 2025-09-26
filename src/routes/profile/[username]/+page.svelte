<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Badge } from '$lib/components/ui/badge';
	import {
		User,
		Calendar,
		MapPin,
		Tag,
		Clock,
		Edit3,
		Share2,
		Heart,
		Eye,
		Award,
		BookOpen
	} from 'lucide-svelte';
	import { page } from '$app/stores';
	import { Avatar } from '$lib/components/ui/avatar';
	import EndorsementButton from '$lib/components/EndorsementButton.svelte';
	import EndorsementList from '$lib/components/EndorsementList.svelte';

	let { data } = $props();
	let { profile, isOwnProfile, currentUser } = $derived(data);

	// Format join date
	const formatJoinDate = (dateStr: string) => {
		return new Date(dateStr).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long'
		});
	};



	// Share profile function
	const shareProfile = async () => {
		if (navigator.share) {
			try {
				await navigator.share({
					title: `${profile.full_name || profile.username}'s Profile`,
					text: `Check out ${profile.full_name || profile.username}'s profile on Arvaya`,
					url: window.location.href
				});
			} catch (err) {
				// Fallback to clipboard
				navigator.clipboard.writeText(window.location.href);
			}
		} else {
			// Fallback to clipboard
			navigator.clipboard.writeText(window.location.href);
		}
	};
</script>

<svelte:head>
	<title>{profile.full_name || profile.username} | Arvaya</title>
	<meta
		name="description"
		content={profile.bio ||
			`${profile.full_name || profile.username}'s profile on Arvaya - exploring India's cultural heritage.`}
	/>
</svelte:head>

<div class="min-h-screen bg-background">
	<div class="container mx-auto max-w-4xl px-4 py-8">
		<!-- Profile Header -->
		<Card.Root class="mb-8">
			<Card.Content class="p-8">
				<div class="flex flex-col items-start gap-6 md:flex-row">
					<!-- Avatar -->
					<div class="flex-shrink-0">
						<Avatar 
							user={profile}
							size="h-24 w-24 md:h-32 md:w-32"
						/>
					</div>

					<!-- Profile Info -->
					<div class="flex-grow space-y-4">
						<div>
							<h1 class="text-3xl font-bold text-foreground md:text-4xl">
								{profile.full_name || profile.username}
							</h1>
							{#if profile.full_name && profile.username}
								<p class="text-xl text-muted-foreground">@{profile.username}</p>
							{/if}
						</div>

						<!-- Profile Stats -->
						<div class="flex flex-wrap gap-4 text-sm text-muted-foreground">
							{#if profile.state}
								<div class="flex items-center gap-1">
									<MapPin class="h-4 w-4" />
									{profile.state}
								</div>
							{/if}
							{#if profile.age}
								<div class="flex items-center gap-1">
									<User class="h-4 w-4" />
									{profile.age} years old
								</div>
							{/if}
							{#if profile.daysSinceJoining !== null}
								<div class="flex items-center gap-1">
									<Calendar class="h-4 w-4" />
									Joined {formatJoinDate(profile.created_at)}
								</div>
							{/if}
						</div>

						<!-- Bio -->
						{#if profile.bio}
							<p class="max-w-2xl leading-relaxed text-muted-foreground">
								{profile.bio}
							</p>
						{/if}

						<!-- Actions -->
						<div class="flex flex-wrap gap-3 pt-2">
							{#if isOwnProfile}
								<Button href="/me" variant="default" size="sm">
									<Edit3 class="mr-2 h-4 w-4" />
									Edit Profile
								</Button>
							{:else}
								<!-- Endorsement Button (only for other users' profiles) -->
								<EndorsementButton 
									userId={profile.id}
									username={profile.username}
									fullName={profile.full_name}
									initialEndorsementCount={profile.endorsements}
									size="sm"
								/>
							{/if}
							<Button variant="outline" size="sm" onclick={shareProfile}>
								<Share2 class="mr-2 h-4 w-4" />
								Share Profile
							</Button>
						</div>
					</div>
				</div>
			</Card.Content>
		</Card.Root>

		<div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
			<!-- Left Column -->
			<div class="space-y-6 lg:col-span-2">
				<!-- Interests & Tags -->
				{#if profile.tags && profile.tags.length > 0}
					<Card.Root>
						<Card.Header>
							<Card.Title class="flex items-center gap-2">
								<Tag class="h-5 w-5 text-blue-600" />
								Interests
							</Card.Title>
						</Card.Header>
						<Card.Content>
							<div class="flex flex-wrap gap-2">
								{#each profile.tags as tag}
									<Badge variant="secondary" class="text-sm">
										{tag}
									</Badge>
								{/each}
							</div>
						</Card.Content>
					</Card.Root>
				{/if}

				<!-- Activity & Achievements -->
				<Card.Root>
					<Card.Header>
						<Card.Title class="flex items-center gap-2">
							<BookOpen class="h-5 w-5 text-green-600" />
							Cultural Journey
						</Card.Title>
						<Card.Description>
							{profile.full_name || profile.username}'s contributions and achievements
						</Card.Description>
					</Card.Header>
					<Card.Content>
						<div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
							<!-- Blogs Written -->
							<div class="flex items-center gap-4 rounded-lg bg-muted/50 p-4">
								<div
									class="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100 dark:bg-blue-900/30"
								>
									📝
								</div>
								<div>
									<p class="font-medium">{profile.blog_count || 0}</p>
									<p class="text-sm text-muted-foreground">
										Blog{(profile.blog_count || 0) !== 1 ? 's' : ''} Written
									</p>
								</div>
							</div>

							<!-- Places Explored -->
							<div class="flex items-center gap-4 rounded-lg bg-muted/50 p-4">
								<div
									class="flex h-12 w-12 items-center justify-center rounded-lg bg-orange-100 dark:bg-orange-900/30"
								>
									🏛️
								</div>
								<div>
									<p class="font-medium">{profile.places_explored || 0}</p>
									<p class="text-sm text-muted-foreground">
										Place{(profile.places_explored || 0) !== 1 ? 's' : ''} Explored
									</p>
								</div>
							</div>

							<!-- Endorsements -->
							<div class="flex items-center gap-4 rounded-lg bg-muted/50 p-4">
								<div
									class="flex h-12 w-12 items-center justify-center rounded-lg bg-green-100 dark:bg-green-900/30"
								>
									👏
								</div>
								<div>
									<p class="font-medium">{profile.endorsements || 0}</p>
									<p class="text-sm text-muted-foreground">
										Endorsement{(profile.endorsements || 0) !== 1 ? 's' : ''} Received
									</p>
								</div>
							</div>

							<!-- Activity Points -->
							<div class="flex items-center gap-4 rounded-lg bg-muted/50 p-4">
								<div
									class="flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100 dark:bg-purple-900/30"
								>
									⭐
								</div>
								<div>
									<p class="font-medium">{profile.activity_points || 0}</p>
									<p class="text-sm text-muted-foreground">Activity Points</p>
								</div>
							</div>
						</div>

						{#if (profile.blog_count || 0) === 0 && (profile.places_explored || 0) === 0 && (profile.endorsements || 0) === 0}
							<div class="mt-4 text-center">
								<p class="text-sm text-muted-foreground">
									{isOwnProfile
										? 'Start your cultural journey by exploring places and writing blogs!'
										: `${profile.full_name || profile.username} is just getting started on their cultural heritage journey.`}
								</p>
							</div>
						{/if}
					</Card.Content>
				</Card.Root>
			</div>

			<!-- Right Column - Profile Stats -->
			<div class="space-y-6">
				<!-- Profile Completion -->
				<Card.Root>
					<Card.Header>
						<Card.Title class="flex items-center gap-2">
							<Award class="h-5 w-5 text-purple-600" />
							Profile
						</Card.Title>
					</Card.Header>
					<Card.Content class="space-y-4">
						<div>
							<div class="mb-2 flex items-center justify-between">
								<span class="text-sm font-medium">Completion</span>
								<span class="text-sm text-muted-foreground">{profile.completionPercentage}%</span>
							</div>
							<div class="h-2 w-full rounded-full bg-muted">
								<div
									class="h-2 rounded-full bg-gradient-to-r from-orange-600 to-red-600 transition-all duration-300"
									style="width: {profile.completionPercentage}%"
								></div>
							</div>
						</div>

						<div class="space-y-3 text-sm">
							{#if profile.daysSinceJoining !== null}
								<div class="flex justify-between">
									<span class="text-muted-foreground">Member for</span>
									<span class="font-medium">
										{profile.daysSinceJoining} day{profile.daysSinceJoining !== 1 ? 's' : ''}
									</span>
								</div>
							{/if}
							<div class="flex justify-between">
								<span class="text-muted-foreground">Activity Points</span>
								<span class="font-medium">{profile.activity_points || 0}</span>
							</div>
							<div class="flex justify-between">
								<span class="text-muted-foreground">Blogs Written</span>
								<span class="font-medium">{profile.blog_count || 0}</span>
							</div>
							<div class="flex justify-between">
								<span class="text-muted-foreground">Places Explored</span>
								<span class="font-medium">{profile.places_explored || 0}</span>
							</div>
							<div class="flex justify-between">
								<span class="text-muted-foreground">Interests</span>
								<span class="font-medium">{profile.tags.length}</span>
							</div>
							{#if profile.state}
								<div class="flex justify-between">
									<span class="text-muted-foreground">Location</span>
									<span class="font-medium">{profile.state}</span>
								</div>
							{/if}
						</div>
					</Card.Content>
				</Card.Root>

				<!-- Endorsements List -->
				{#if profile.endorsements && profile.endorsements > 0}
					<EndorsementList 
						userId={profile.id}
						username={profile.username}
						showTitle={true}
					/>
				{/if}

				<!-- Quick Facts -->
				{#if profile.gender || profile.age}
					<Card.Root>
						<Card.Header>
							<Card.Title class="flex items-center gap-2">
								<User class="h-5 w-5 text-indigo-600" />
								About
							</Card.Title>
						</Card.Header>
						<Card.Content class="space-y-3 text-sm">
							{#if profile.gender}
								<div class="flex justify-between">
									<span class="text-muted-foreground">Gender</span>
									<span class="font-medium">{profile.gender}</span>
								</div>
							{/if}
							{#if profile.age}
								<div class="flex justify-between">
									<span class="text-muted-foreground">Age</span>
									<span class="font-medium">{profile.age} years old</span>
								</div>
							{/if}
							{#if profile.date_of_birth}
								<div class="flex justify-between">
									<span class="text-muted-foreground">Birthday</span>
									<span class="font-medium">
										{new Date(profile.date_of_birth).toLocaleDateString('en-US', {
											month: 'long',
											day: 'numeric'
										})}
									</span>
								</div>
							{/if}
						</Card.Content>
					</Card.Root>
				{/if}
			</div>
		</div>
	</div>
</div>
