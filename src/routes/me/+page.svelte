<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import { Badge } from '$lib/components/ui/badge';
	import { enhance } from '$app/forms';
	import { User, Calendar, MapPin, Tag, FileText, X, Award, Star, Upload, Trash2 } from 'lucide-svelte';
	import { Avatar } from '$lib/components/ui/avatar';

	let { data, form } = $props();
	let { session, user, profile, completionPercentage } = $derived(data);
	
	// Calculate completion status and points to earn
	const isFullyComplete = $derived(completionPercentage === 100);
	const pointsToEarn = $derived(isFullyComplete ? 0 : 50);

	// Profile picture upload state
	let uploadStatus = $state('');
	let isUploading = $state(false);
	let uploadProgress = $state(0);

	async function handleFileSelect(event: Event) {
		const target = event.target as HTMLInputElement;
		const file = target.files?.[0];
		
		if (!file) return;

		// Validate file
		if (file.size > 5 * 1024 * 1024) {
			uploadStatus = 'Error: File size must be less than 5MB';
			return;
		}

		if (!file.type.startsWith('image/')) {
			uploadStatus = 'Error: Please select a valid image file';
			return;
		}

		isUploading = true;
		uploadStatus = 'Uploading...';
		uploadProgress = 0;

		try {
			const formData = new FormData();
			formData.append('file', file);

			const response = await fetch('/api/upload-profile-picture', {
				method: 'POST',
				body: formData
			});

			const result = await response.json();

			if (response.ok) {
				uploadStatus = 'Upload successful!';
				// Refresh the page to show the new profile picture
				window.location.reload();
			} else {
				uploadStatus = `Error: ${result.error || 'Upload failed'}`;
			}
		} catch (error) {
			uploadStatus = 'Error: Upload failed. Please try again.';
			console.error('Upload error:', error);
		} finally {
			isUploading = false;
			// Clear status after 3 seconds
			setTimeout(() => {
				uploadStatus = '';
			}, 3000);
		}

		// Reset file input
		target.value = '';
	}

	// Handle profile picture deletion
	async function deleteProfilePicture() {
		if (!profile?.profile_image_url) return;

		isUploading = true;
		uploadStatus = 'Deleting...';

		try {
			const response = await fetch('/api/upload-profile-picture', {
				method: 'DELETE'
			});

			const result = await response.json();

			if (response.ok) {
				uploadStatus = 'Profile picture deleted successfully!';
				// Refresh the page to show the updated avatar
				window.location.reload();
			} else {
				uploadStatus = `Error: ${result.error || 'Delete failed'}`;
			}
		} catch (error) {
			uploadStatus = 'Error: Delete failed. Please try again.';
			console.error('Delete error:', error);
		} finally {
			isUploading = false;
			// Clear status after 3 seconds
			setTimeout(() => {
				uploadStatus = '';
			}, 3000);
		}
	}

	// Indian states and union territories
	const indianStates = [
		'Andhra Pradesh',
		'Arunachal Pradesh',
		'Assam',
		'Bihar',
		'Chhattisgarh',
		'Goa',
		'Gujarat',
		'Haryana',
		'Himachal Pradesh',
		'Jharkhand',
		'Karnataka',
		'Kerala',
		'Madhya Pradesh',
		'Maharashtra',
		'Manipur',
		'Meghalaya',
		'Mizoram',
		'Nagaland',
		'Odisha',
		'Punjab',
		'Rajasthan',
		'Sikkim',
		'Tamil Nadu',
		'Telangana',
		'Tripura',
		'Uttar Pradesh',
		'Uttarakhand',
		'West Bengal',
		// Union Territories
		'Andaman and Nicobar Islands',
		'Chandigarh',
		'Dadra and Nagar Haveli and Daman and Diu',
		'Delhi',
		'Jammu and Kashmir',
		'Ladakh',
		'Lakshadweep',
		'Puducherry'
	];

	const genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

	// Tags management
	let tagInput = $state('');
	// svelte-ignore state_referenced_locally
	let currentTags = $state(
		profile?.tags ? profile.tags.split(',').filter((t: string) => t.trim()) : []
	);

	function addTag() {
		if (tagInput.trim() && !currentTags.includes(tagInput.trim())) {
			currentTags = [...currentTags, tagInput.trim()];
			tagInput = '';
		}
	}

	function removeTag(tag: string) {
		currentTags = currentTags.filter((t: string) => t !== tag);
	}

	function handleKeyPress(event: KeyboardEvent) {
		if (event.key === 'Enter') {
			event.preventDefault();
			addTag();
		}
	}
</script>

<svelte:head>
	<title>My Profile | Arvaya</title>
	<meta name="description" content="Customize your Arvaya profile and preferences." />
</svelte:head>

<div class="min-h-screen bg-background">
	<div class="container mx-auto max-w-4xl px-4 py-8">
		<!-- Header -->
		<div class="mb-8">
			<h1 class="mb-2 text-3xl font-bold text-foreground md:text-4xl">My Profile</h1>
			<p class="text-lg text-muted-foreground">
				Customize your profile to enhance your Arvaya experience
			</p>
		</div>

		<!-- Profile Picture Section -->
		<Card.Root class="mb-8">
			<Card.Header>
				<Card.Title class="flex items-center gap-2">
					<User class="h-5 w-5 text-orange-600" />
					Profile Picture
				</Card.Title>
				<Card.Description>
					{#if profile?.profile_image_url}
						Your custom profile picture
					{:else}
						Auto-generated avatar or upload a custom picture
					{/if}
				</Card.Description>
			</Card.Header>
			<Card.Content class="space-y-4">
				<!-- Current Profile Picture -->
				<div class="flex items-center gap-4">
					<Avatar 
						user={profile || user}
						size="h-20 w-20"
					/>
					<div class="space-y-2">
						{#if profile?.profile_image_url}
							<p class="text-sm font-medium">Custom Profile Picture</p>
							<p class="text-xs text-muted-foreground">
								Your uploaded profile picture is displayed across the site.
							</p>
						{:else}
							<p class="text-sm font-medium">Auto-generated Avatar</p>
							<p class="text-xs text-muted-foreground">
								Upload a custom picture or keep the auto-generated avatar.
							</p>
						{/if}
					</div>
				</div>

				<!-- Upload Section -->
				<div class="space-y-3">
					<div class="flex flex-wrap gap-2">
						<!-- File Input (Hidden) -->
						<input
							type="file"
							id="profilePicture"
							accept="image/*"
							class="hidden"
							onchange={handleFileSelect}
						/>
						<Button
							type="button"
							variant="outline"
							size="sm"
							onclick={() => document.getElementById('profilePicture')?.click()}
							disabled={isUploading}
							class="flex items-center gap-2"
						>
							<Upload class="h-4 w-4" />
							{isUploading ? 'Uploading...' : 'Choose Image'}
						</Button>

						{#if profile?.profile_image_url}
							<Button
								type="button"
								variant="outline"
								size="sm"
								onclick={deleteProfilePicture}
								disabled={isUploading}
								class="flex items-center gap-2 text-red-600 hover:text-red-700"
							>
								<Trash2 class="h-4 w-4" />
								Remove
							</Button>
						{/if}
					</div>

					<!-- Upload Status -->
					{#if uploadStatus}
						<div class="text-sm {uploadStatus.startsWith('Error') ? 'text-red-600' : uploadStatus.includes('successful') || uploadStatus.includes('Uploading') || uploadStatus.includes('Deleting') ? 'text-green-600' : 'text-blue-600'}">
							{uploadStatus}
						</div>
					{/if}

					<!-- Upload Guidelines -->
					<p class="text-xs text-muted-foreground">
						Upload a profile picture (max 5MB). Supported formats: JPG, PNG, GIF, WebP.
					</p>
				</div>
			</Card.Content>
		</Card.Root>

		<!-- Profile Completion Progress -->
		<Card.Root class="mb-8 {isFullyComplete ? 'border-green-200 bg-green-50/50 dark:border-green-800 dark:bg-green-950/50' : 'border-orange-200 bg-orange-50/50 dark:border-orange-800 dark:bg-orange-950/50'}">
			<Card.Header>
				<Card.Title class="flex items-center gap-2">
					{#if isFullyComplete}
						<Star class="h-5 w-5 text-green-600" />
						Profile Complete!
					{:else}
						<Award class="h-5 w-5 text-orange-600" />
						Complete Your Profile
					{/if}
				</Card.Title>
				<Card.Description>
					{#if isFullyComplete}
						Congratulations! Your profile is 100% complete. You've earned all completion rewards.
					{:else}
						Complete your profile to earn {pointsToEarn} activity points and unlock the full Arvaya experience.
					{/if}
				</Card.Description>
			</Card.Header>
			<Card.Content>
				<div class="space-y-3">
					<!-- Progress Bar -->
					<div class="space-y-2">
						<div class="flex justify-between text-sm">
							<span class="text-muted-foreground">Profile Completion</span>
							<span class="font-medium {isFullyComplete ? 'text-green-600' : 'text-orange-600'}">{completionPercentage}%</span>
						</div>
						<div class="w-full bg-muted rounded-full h-2">
							<div 
								class="h-2 rounded-full transition-all duration-500 {isFullyComplete ? 'bg-green-500' : 'bg-orange-500'}" 
								style="width: {completionPercentage}%"
							></div>
						</div>
					</div>

					{#if !isFullyComplete}
						<!-- Points Reward -->
						<div class="flex items-center justify-between p-3 bg-background rounded-lg border">
							<div class="flex items-center gap-2">
								<Award class="h-4 w-4 text-orange-500" />
								<span class="text-sm font-medium">Completion Reward</span>
							</div>
							<Badge variant="secondary" class="bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300">
								+{pointsToEarn} points
							</Badge>
						</div>
					{:else}
						<!-- Completed State -->
						<div class="flex items-center justify-center p-3 bg-background rounded-lg border border-green-200 dark:border-green-800">
							<div class="flex items-center gap-2 text-green-600">
								<Star class="h-4 w-4" />
								<span class="text-sm font-medium">Profile Complete - 50 Points Earned!</span>
							</div>
						</div>
					{/if}
				</div>
			</Card.Content>
		</Card.Root>

		<!-- Profile Form -->
		<form method="POST" action="?/updateProfile" use:enhance>
			<div class="grid gap-8">
				<!-- Basic Information -->
				<Card.Root>
					<Card.Header>
						<Card.Title class="flex items-center gap-2">
							<User class="h-5 w-5 text-orange-600" />
							Basic Information
						</Card.Title>
						<Card.Description>Your basic profile information</Card.Description>
					</Card.Header>
					<Card.Content class="space-y-6">
						<div class="grid grid-cols-1 gap-6 md:grid-cols-2">
							<!-- Full Name -->
							<div class="space-y-2">
								<Label for="fullName">Full Name</Label>
								<Input
									id="fullName"
									name="fullName"
									type="text"
									placeholder="Enter your full name"
									value={profile?.full_name || user?.user_metadata?.full_name || ''}
									required
								/>
								{#if form?.errors && 'fullName' in form.errors}
									<p class="text-sm text-destructive">{form.errors.fullName}</p>
								{/if}
							</div>

							<!-- Username -->
							<div class="space-y-2">
								<Label for="username">Username</Label>
								<Input
									id="username"
									name="username"
									type="text"
									placeholder="Choose a unique username"
									value={profile?.username || ''}
									required
								/>
								{#if form?.errors?.username}
									<p class="text-sm text-destructive">{form.errors.username}</p>
								{/if}
							</div>

							<!-- Gender -->
							<div class="space-y-2">
								<Label for="gender">Gender</Label>
								<select
									id="gender"
									name="gender"
									class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50"
								>
									<option value="">Select gender</option>
									{#each genderOptions as option}
										<option value={option} selected={profile?.gender === option}>
											{option}
										</option>
									{/each}
								</select>
							</div>

							<!-- Date of Birth -->
							<div class="space-y-2">
								<Label for="dateOfBirth">Date of Birth</Label>
								<Input
									id="dateOfBirth"
									name="dateOfBirth"
									type="date"
									value={profile?.date_of_birth || user?.user_metadata?.date_of_birth || ''}
								/>
							</div>
						</div>

						<!-- State -->
						<div class="space-y-2">
							<Label for="state">State/Union Territory</Label>
							<select
								id="state"
								name="state"
								class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50"
							>
								<option value="">Select your state/UT</option>
								{#each indianStates as state}
									<option value={state} selected={profile?.state === state}>
										{state}
									</option>
								{/each}
							</select>
						</div>
					</Card.Content>
				</Card.Root>

				<!-- Interests & Bio -->
				<Card.Root>
					<Card.Header>
						<Card.Title class="flex items-center gap-2">
							<Tag class="h-5 w-5 text-blue-600" />
							Interests & Bio
						</Card.Title>
						<Card.Description>Tell us about your interests and yourself</Card.Description>
					</Card.Header>
					<Card.Content class="space-y-6">
						<!-- Tags/Interests -->
						<div class="space-y-2">
							<Label for="tags">Interests & Tags</Label>
							<div class="space-y-3">
								<div class="flex gap-2">
									<Input
										id="tagInput"
										type="text"
										placeholder="Add an interest (e.g., Ancient History, Art, Culture)"
										bind:value={tagInput}
										onkeypress={handleKeyPress}
									/>
									<Button type="button" variant="outline" onclick={addTag}>Add</Button>
								</div>

								{#if currentTags.length > 0}
									<div class="flex flex-wrap gap-2">
										{#each currentTags as tag}
											<Badge variant="secondary" class="flex items-center gap-1">
												{tag}
												<button
													type="button"
													onclick={() => removeTag(tag)}
													class="ml-1 hover:text-destructive"
												>
													<X class="h-3 w-3" />
												</button>
											</Badge>
										{/each}
									</div>
								{/if}

								<input type="hidden" name="tags" value={currentTags.join(',')} />
							</div>
						</div>

						<!-- Bio -->
						<div class="space-y-2">
							<Label for="bio">Bio</Label>
							<textarea
								id="bio"
								name="bio"
								rows="4"
								class="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50"
								placeholder="Tell us about yourself, your interests in Indian culture and heritage..."
								value={profile?.bio || ''}
							></textarea>
						</div>
					</Card.Content>
				</Card.Root>

				<!-- Save Button -->
				<div class="flex justify-end gap-4">
					<Button variant="outline" href="/dashboard">Cancel</Button>
					<Button
						type="submit"
						class="bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700"
					>
						Save Profile
					</Button>
				</div>
			</div>
		</form>

		{#if form?.success}
			<div
				class="mt-4 rounded-lg border border-green-200 bg-green-50 p-4 dark:border-green-800 dark:bg-green-900/20"
			>
				<p class="text-green-700 dark:text-green-300">Profile updated successfully!</p>
			</div>
		{/if}

		<!-- Activity Metrics Display -->
		<Card.Root class="mt-8">
			<Card.Header>
				<Card.Title class="flex items-center gap-2">⭐ Activity Metrics</Card.Title>
				<Card.Description>
					Your current activity stats and points earned
				</Card.Description>
			</Card.Header>
			<Card.Content>
				<div class="grid grid-cols-2 gap-4 sm:grid-cols-4">
					<div class="text-center">
						<div class="text-2xl font-bold text-blue-600">{profile?.blog_count || 0}</div>
						<div class="text-sm text-muted-foreground">Blogs</div>
						<form method="post" action="?/incrementBlogs" use:enhance class="mt-2">
							<Button type="submit" size="sm" variant="outline" class="h-8 text-xs">+1 Blog</Button>
						</form>
					</div>
					<div class="text-center">
						<div class="text-2xl font-bold text-orange-600">{profile?.places_explored || 0}</div>
						<div class="text-sm text-muted-foreground">Places</div>
						<form method="post" action="?/incrementPlaces" use:enhance class="mt-2">
							<Button type="submit" size="sm" variant="outline" class="h-8 text-xs">+1 Place</Button
							>
						</form>
					</div>
					<div class="text-center">
						<div class="text-2xl font-bold text-green-600">{profile?.endorsements || 0}</div>
						<div class="text-sm text-muted-foreground">Endorsements</div>
						<form method="post" action="?/incrementEndorsements" use:enhance class="mt-2">
							<Button type="submit" size="sm" variant="outline" class="h-8 text-xs"
								>+1 Endorse</Button
							>
						</form>
					</div>
					<div class="text-center">
						<div class="text-2xl font-bold text-purple-600">{profile?.activity_points || 0}</div>
						<div class="text-sm text-muted-foreground">Points</div>
						<form method="post" action="?/addActivityPoints" use:enhance class="mt-2">
							<input type="hidden" name="points" value="10" />
							<Button type="submit" size="sm" variant="outline" class="h-8 text-xs"
								>+10 Points</Button
							>
						</form>
					</div>
				</div>
				<div class="mt-4 text-center text-xs text-muted-foreground">
					<p>
						Testing buttons - in production, these would be updated automatically when you perform
						activities.
					</p>
					{#if !isFullyComplete}
						<div class="mt-4 p-3 bg-orange-50 dark:bg-orange-900/20 rounded-lg border border-orange-200 dark:border-orange-800">
							<p class="text-sm text-orange-700 dark:text-orange-300">
								Complete your profile to earn {pointsToEarn} more points automatically!
							</p>
						</div>
					{/if}
				</div>
			</Card.Content>
		</Card.Root>


	</div>
</div>
