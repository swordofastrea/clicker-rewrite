import type { OnStart } from "@flamework/core";
import { Service } from "@flamework/core";
import { Players } from "@rbxts/services";

import type { ProfileTemplate } from "./dataservice";

@Service()
export class Leaderstats implements OnStart {
	public onStart(): void {
		Players.PlayerAdded.Connect((player: Player) => {
			const leaderstats = new Instance("Folder");
			leaderstats.Parent = player;
			leaderstats.Name = "leaderstats";

			const Clicks = new Instance("IntValue");
			Clicks.Parent = leaderstats;
			Clicks.Name = "Clicks";
			Clicks.Value = 0;

			const Rebirths = new Instance("IntValue");
			Rebirths.Parent = leaderstats;
			Rebirths.Name = "Rebirths";
			Rebirths.Value = 0;
		});
	}

	public UpdateLeaderstats(player: Player, stat: keyof ProfileTemplate, value: number): string {
		try {
			const leaderstats = player.FindFirstChild("leaderstats");
			if (leaderstats) {
				const updatedStat = leaderstats.FindFirstChild(stat) as IntValue;
				updatedStat.Value = value;
			}

			return `Successfully updated leaderstats for player ${player.Name} for stat ${stat} to ${value}`;
		} catch (err) {
			error(`Failed to update leaderstats for player ${player.Name}: ${err}`);
		}
	}
}
