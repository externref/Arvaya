<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Badge } from '$lib/components/ui/badge';
	import { Heart, HeartOff, Users } from 'lucide-svelte';
	import { invalidateAll } from '$app/navigation';

	interface Props {
		userId: string;
		username?: string;
		fullName?: string;
		initialEndorsementCount?: number;
		initialHasEndorsed?: boolean;
		showLabel?: boolean;
		size?: 'sm' | 'md' | 'lg';
	}

	let { 
		userId, 
		username, 
		fullName, 
		initialEndorsementCount = 0, 
		initialHasEndorsed = false,
		showLabel = true,
		size = 'md'
	}: Props = $props();

	let hasEndorsed = $state(initialHasEndorsed);
	let endorsementCount = $state(initialEndorsementCount);
	let isLoading = $state(false);
	let statusMessage = $state('');

	// Reactive size classes
	const buttonSizes = {
		sm: 'h-8 px-3 text-xs',
		md: 'h-9 px-4 text-sm',
		lg: 'h-10 px-6 text-base'
	};

	const iconSizes = {
		sm: 'h-3 w-3',
		md: 'h-4 w-4',
		lg: 'h-5 w-5'
	};

	async function toggleEndorsement() {
		if (isLoading) return;

		isLoading = true;
		statusMessage = '';

		try {
			const method = hasEndorsed ? 'DELETE' : 'POST';
			const response = await fetch('/api/endorsements', {
				method,
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					endorsed_user_id: userId
				})
			});

			const result = await response.json();

			if (response.ok) {
				// Update local state
				if (hasEndorsed) {
					hasEndorsed = false;
					endorsementCount = Math.max(0, endorsementCount - 1);
					statusMessage = 'Endorsement removed';
				} else {
					hasEndorsed = true;
					endorsementCount = endorsementCount + 1;
					statusMessage = `Endorsed ${fullName || username || 'user'}!`;
				}

				// Invalidate all data to refresh profile pages
				await invalidateAll();
			} else {
				statusMessage = result.error || 'Failed to update endorsement';
			}
		} catch (error) {
			console.error('Endorsement error:', error);
			statusMessage = 'Failed to update endorsement. Please try again.';
		} finally {
			isLoading = false;
			// Clear status message after 3 seconds
			setTimeout(() => {
				statusMessage = '';
			}, 3000);
		}
	}

	// Load endorsement status on component mount
	async function loadEndorsementStatus() {
		try {
			const response = await fetch(`/api/endorsements?user_id=${userId}`);
			const result = await response.json();

			if (response.ok) {
				hasEndorsed = result.has_endorsed;
				endorsementCount = result.endorsement_count;
			}
		} catch (error) {
			console.error('Failed to load endorsement status:', error);
		}
	}

	// Load status when component mounts
	$effect(() => {
		if (userId) {
			loadEndorsementStatus();
		}
	});
</script>

<div class="flex items-center gap-2">
	<!-- Endorsement Button -->
	<Button
		variant={hasEndorsed ? "default" : "outline"}
		size="sm"
		class={`${buttonSizes[size]} ${hasEndorsed ? 'bg-red-600 hover:bg-red-700 text-white' : 'hover:bg-red-50 hover:text-red-700 hover:border-red-200'}`}
		onclick={toggleEndorsement}
		disabled={isLoading}
	>
		{#if hasEndorsed}
			<Heart class={`${iconSizes[size]} mr-2 fill-current`} />
		{:else}
			<HeartOff class={`${iconSizes[size]} mr-2`} />
		{/if}
		
		{#if showLabel}
			{hasEndorsed ? 'Endorsed' : 'Endorse'}
		{/if}
		
		{#if isLoading}
			<div class={`${iconSizes[size]} ml-2 animate-spin rounded-full border-2 border-current border-t-transparent`}></div>
		{/if}
	</Button>

	<!-- Endorsement Count Badge -->
	{#if endorsementCount > 0}
		<Badge variant="secondary" class="flex items-center gap-1">
			<Users class={iconSizes[size]} />
			{endorsementCount}
		</Badge>
	{/if}
</div>

<!-- Status Message -->
{#if statusMessage}
	<p class={`mt-2 text-xs ${statusMessage.includes('Failed') || statusMessage.includes('Error') ? 'text-red-600' : 'text-green-600'}`}>
		{statusMessage}
	</p>
{/if}