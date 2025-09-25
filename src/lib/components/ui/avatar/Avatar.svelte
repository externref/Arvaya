<script lang="ts">
	import { createAvatarProps } from '$lib/utils/avatar';
	
	interface Props {
		user: { username?: string; full_name?: string; id?: string; email?: string; profile_image_url?: string };
		size?: string;
		class?: string;
	}
	
	let { user, size = 'h-10 w-10', class: className = '' }: Props = $props();
	
	const avatarProps = $derived(createAvatarProps(user, size));
	const finalClass = $derived(`${avatarProps.class} ${className}`);
</script>

<img 
	src={avatarProps.src}
	alt={avatarProps.alt}
	class={finalClass}
	loading="lazy"
/>