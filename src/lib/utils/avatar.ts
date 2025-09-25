import multiavatar from '@multiavatar/multiavatar';

/**
 * Generate a unique avatar SVG string based on user identifier
 * @param seed - Unique identifier for the user (username, email, or ID)
 * @returns SVG string for the avatar
 */
export function generateAvatar(seed: string): string {
	if (!seed) {
		seed = 'default-user';
	}
	
	return multiavatar(seed);
}

/**
 * Generate a data URL for the avatar that can be used directly in img src
 * @param seed - Unique identifier for the user
 * @returns Data URL string
 */
export function generateAvatarDataUrl(seed: string): string {
	const svgString = generateAvatar(seed);
	const encodedSvg = encodeURIComponent(svgString);
	return `data:image/svg+xml,${encodedSvg}`;
}

/**
 * Create an avatar component props object
 * @param user - User object with username, full_name, or id
 * @param size - Size class for the avatar (default: 'h-24 w-24')
 * @returns Object with src and alt properties
 */
export function createAvatarProps(
	user: { username?: string; full_name?: string; id?: string; email?: string },
	size: string = 'h-24 w-24'
) {
	// Use username as primary seed, fallback to email or id
	const seed = user.username || user.email || user.id || 'default';
	const displayName = user.full_name || user.username || 'User';
	
	return {
		src: generateAvatarDataUrl(seed),
		alt: `${displayName}'s avatar`,
		class: `${size} rounded-full object-cover border-2 border-border shadow-lg`
	};
}