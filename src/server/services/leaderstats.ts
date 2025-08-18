import type { OnStart } from "@flamework/core";
import { Service } from "@flamework/core";
import { Players } from "@rbxts/services";

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

	public async UpdateLeaderstats(
		player: Player,
		stat: string,
		value: number,
	): Promise<number> {
		const leaderstats = player.FindFirstChild("leaderstats");
		if (leaderstats) {
			const updatedStat = leaderstats.FindFirstChild(stat) as IntValue;
			updatedStat.Value = value;
			return updatedStat.Value;
		}
		return error("Leaderstats not found");
	}
}
