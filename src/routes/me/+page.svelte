<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import * as Card from '$lib/components/ui/card';
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import { Badge } from '$lib/components/ui/badge';
	import { enhance } from '$app/forms';
	import { User, Calendar, MapPin, Tag, FileText, X } from 'lucide-svelte';

	let { data, form } = $props();
	let { session, user, profile } = $derived(data);

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
	let currentTags = $state(profile?.tags ? profile.tags.split(',').filter((t) => t.trim()) : []);

	function addTag() {
		if (tagInput.trim() && !currentTags.includes(tagInput.trim())) {
			currentTags = [...currentTags, tagInput.trim()];
			tagInput = '';
		}
	}

	function removeTag(tag: string) {
		currentTags = currentTags.filter((t) => t !== tag);
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
								{#if form?.errors?.fullName}
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
	</div>
</div>
