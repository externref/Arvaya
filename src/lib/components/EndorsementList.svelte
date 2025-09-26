<script lang="ts">
	import { Avatar } from '$lib/components/ui/avatar';
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Users, Calendar } from 'lucide-svelte';

	interface Props {
		userId: string;
		username?: string;
		showTitle?: boolean;
	}

	let { userId, username, showTitle = true }: Props = $props();

	interface Endorser {
		username: string;
		full_name?: string;
	}

	interface Endorsement {
		endorser: Endorser;
		created_at: string;
	}

	let endorsements = $state<Endorsement[]>([]);
	let isLoading = $state(false);
	let hasLoaded = $state(false);
	let error = $state('');

	async function loadEndorsements() {
		if (isLoading || hasLoaded) return;

		isLoading = true;
		error = '';

		try {
			const response = await fetch(`/api/endorsements/list?user_id=${userId}&limit=20`);
			const result = await response.json();

			if (response.ok) {
				endorsements = result.endorsements;
				hasLoaded = true;
			} else {
				error = result.error || 'Failed to load endorsements';
			}
		} catch (err) {
			console.error('Failed to load endorsements:', err);
			error = 'Failed to load endorsements';
		} finally {
			isLoading = false;
		}
	}

	function formatDate(dateStr: string) {
		return new Date(dateStr).toLocaleDateString('en-US', {
			month: 'short',
			day: 'numeric',
			year: 'numeric'
		});
	}
</script>

<Card.Root>
	{#if showTitle}
		<Card.Header>
			<Card.Title class="flex items-center gap-2">
				<Users class="h-5 w-5 text-green-600" />
				Endorsements {username ? `for ${username}` : ''}
			</Card.Title>
		</Card.Header>
	{/if}
	
	<Card.Content class="p-4">
		{#if !hasLoaded}
			<Button 
				variant="outline" 
				size="sm" 
				onclick={loadEndorsements}
				disabled={isLoading}
				class="w-full"
			>
				{#if isLoading}
					<div class="h-4 w-4 mr-2 animate-spin rounded-full border-2 border-current border-t-transparent"></div>
					Loading endorsements...
				{:else}
					<Users class="h-4 w-4 mr-2" />
					View Endorsements
				{/if}
			</Button>
		{:else if endorsements.length > 0}
			<div class="space-y-3 max-h-96 overflow-y-auto">
				{#each endorsements as endorsement}
					<div class="flex items-center gap-3 p-3 rounded-lg bg-muted/50">
						<Avatar 
							user={endorsement.endorser}
							size="h-10 w-10"
						/>
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2">
								<a 
									href="/profile/{endorsement.endorser.username}"
									class="font-medium text-foreground hover:text-primary truncate"
								>
									{endorsement.endorser.full_name || endorsement.endorser.username}
								</a>
								{#if endorsement.endorser.full_name}
									<span class="text-sm text-muted-foreground truncate">
										@{endorsement.endorser.username}
									</span>
								{/if}
							</div>
							<div class="flex items-center gap-1 text-xs text-muted-foreground">
								<Calendar class="h-3 w-3" />
								{formatDate(endorsement.created_at)}
							</div>
						</div>
					</div>
				{/each}
			</div>
		{:else}
			<div class="text-center py-8 text-muted-foreground">
				<Users class="h-12 w-12 mx-auto mb-3 opacity-50" />
				<p class="text-sm">No endorsements yet</p>
				<p class="text-xs mt-1">
					{username ? `${username} hasn't` : "This user hasn't"} received any endorsements yet.
				</p>
			</div>
		{/if}

		{#if error}
			<div class="text-center py-4">
				<p class="text-sm text-red-600">{error}</p>
				<Button 
					variant="outline" 
					size="sm" 
					onclick={() => { hasLoaded = false; loadEndorsements(); }}
					class="mt-2"
				>
					Try Again
				</Button>
			</div>
		{/if}
	</Card.Content>
</Card.Root>