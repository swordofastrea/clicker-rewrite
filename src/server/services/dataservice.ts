import type { OnStart } from "@flamework/core";
import { Flamework, Service } from "@flamework/core";
import type { Profile } from "@rbxts/profile-store";
import ProfileStore from "@rbxts/profile-store";
import { Players } from "@rbxts/services";

import type { Leaderstats } from "./leaderstats";

interface ProfileTemplate {
	Clicks: number;
	Rebirths: number;
}

@Service()
export class DataService implements OnStart {
	private readonly Profiles: Map<number, Profile<ProfileTemplate>> = new Map<
		number,
		Profile<ProfileTemplate>
	>();
	private readonly profileTemplate: ProfileTemplate = {
		Clicks: 0,
		Rebirths: 0,
	};
	private readonly profileStore = ProfileStore.New("PlayerData", this.profileTemplate);
	private readonly validValuesGuard = Flamework.createGuard<keyof ProfileTemplate>();

	constructor(private readonly leaderstats: Leaderstats) {}

	public onStart(): void {
		Players.PlayerAdded.Connect((player: Player) => {
			this.LoadPlayerProfile(player);
		});
		Players.PlayerRemoving.Connect((player: Player) => {
			this.SavePlayerProfile(player);
		});
		for (const player of Players.GetPlayers()) {
			this.LoadPlayerProfile(player);
		}
	}

	public LoadPlayerProfile(player: Player): void {
		try {
			const profile = this.profileStore.StartSessionAsync("Player_" + player.UserId);
			this.Profiles.set(player.UserId, profile);
			profile.Reconcile();
			print("Loaded profile for player ", player.Name, " with data: ", profile.Data);
		} catch (err) {
			player.Kick(
				`Failed to load profile for player ${player.Name}: ${err}. Please try rejoining.`,
			);
		}
	}

	public SavePlayerProfile(player: Player): void {
		try {
			const profile = this.Profiles.get(player.UserId);
			if (profile) {
				profile.EndSession();
				print("Saved profile for player ", player.Name, " with data: ", profile.Data);
				this.Profiles.delete(player.UserId);
			}
		} catch (err) {
			error(`Failed to save profile for player ${player.Name}: ${err}. Data may be lost.`);
		}
	}

	public GetPlayerProfile(player: Player): ProfileTemplate {
		try {
			const playerProfile = this.Profiles.get(player.UserId)! as Profile<ProfileTemplate>;
			return playerProfile.Data;
		} catch (err) {
			return error(`Player profile not found for ${player.Name}: ${err}`);
		}
	}

	public UpdatePlayerLeaderstatData(player: Player, stat: string, value: number): string {
		try {
			const playerProfile = this.Profiles.get(player.UserId);
			if (playerProfile && this.validValuesGuard(stat)) {
				playerProfile.Data[stat] = value;
				this.leaderstats.UpdateLeaderstats(player, stat, value);
			}

			return `Updated leaderstats for ${player.Name} for stat ${stat} to ${value}`;
		} catch (err) {
			return error(`Failed to update leaderstats for ${player.Name}: ${err}`);
		}
	}
}
