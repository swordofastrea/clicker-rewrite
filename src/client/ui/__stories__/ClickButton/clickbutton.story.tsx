import React from "@rbxts/react";
import ReactRoblox from "@rbxts/react-roblox";
import { CreateReactStory } from "@rbxts/ui-labs";

const controls = {
    String: "Click!",
}

const story = CreateReactStory(
    {
        controls,
        react: React,
        reactRoblox: ReactRoblox,
    },
    (_props) => {
        return <frame Size={UDim2.fromOffset(100, 100)} />;
    }
);

export = story;
