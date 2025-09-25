<script lang="ts">
	import type { HTMLAttributes } from 'svelte/elements';
	import { badgeVariants, type Variant } from './index.js';
	import { cn } from '$lib/utils.js';

	type $$Props = HTMLAttributes<HTMLDivElement> & {
		variant?: Variant;
	};

	let { variant = 'default', class: className, ...restProps }: $$Props = $props();
</script>

<!-- svelte-ignore slot_element_deprecated -->
<div class={cn(badgeVariants({ variant }), className)} {...restProps}>
	<slot />
</div>
