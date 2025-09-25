<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/branding/icon.png';
	import Navbar from '$lib/components/persist/Navbar.svelte';
	import { ModeWatcher } from 'mode-watcher';
	import { invalidate } from '$app/navigation';
	import { onMount } from 'svelte';
	let { data, children } = $props();
	let { session, supabase } = $derived(data);
	onMount(() => {
		const { data } = supabase.auth.onAuthStateChange((_, newSession) => {
			if (newSession?.expires_at !== session?.expires_at) {
				invalidate('supabase:auth');
			}
		});
		return () => data.subscription.unsubscribe();
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>arvaya | Exploring India's Cultural Heritage and Traditions</title>
</svelte:head>

<ModeWatcher />
<div>
	<Navbar />
	{@render children?.()}
</div>
