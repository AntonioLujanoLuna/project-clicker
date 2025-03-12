# Project Document for *project-clicker*

## 1. Project Overview
- **Game Title**: *project-clicker*  
- **Genre**: Incremental/Clicker Game  
- **Platform**: Steam (Windows, Mac, Linux)  
- **Development Language**: Lua with Love 2d framework  
- **Target Playtime**: 20 hours  

*project-clicker* is an eco-themed clicker game set in a solarpunk-inspired world. Players take charge of a small community tasked with rebuilding a sustainable society after an environmental collapse. By gathering resources, constructing buildings, and deploying specialized robots, players transform a modest village into a thriving, green metropolis. A key challenge is managing pollution, requiring players to balance growth with environmental health through green technologies.

---

## 2. Theme and Setting
- **Theme**: Solarpunk and Sustainability  
- **Setting**: A post-apocalyptic Earth where humanity rebuilds using eco-friendly technology.  
- **Story**: Following a global environmental collapse, players lead a community in restoring the planet. The narrative progresses through milestones (e.g., achieving carbon neutrality) and random events, emphasizing hope, renewal, and sustainable innovation.  

The solarpunk aesthetic combines lush natural elements—like greenery and flowing water—with futuristic, clean-energy tech such as solar panels and wind turbines. This fusion reinforces the game’s core message: sustainable growth is essential for survival and prosperity.

---

## 3. Visual Style
- **Art Style**: Pixel Art (using 16x16 or 32x32 sprites)  
- **Color Palette**:  
  - **Healthy Areas**: Bright greens, blues, and earthy browns to depict thriving ecosystems.  
  - **Polluted Areas**: Dull grays, browns, and murky greens to show environmental decay.  
- **User Interface (UI)**: Minimalistic and intuitive, featuring:  
  - Resource counters (e.g., Wood, Stone, Food).  
  - A pollution bar to track environmental impact.  
  - Simple buttons and icons for actions.  
- **Animations**: Subtle pixel-based animations, such as workers moving, resources appearing with a “pop,” or wind turbines spinning, to keep the game dynamic without overwhelming the player.  

As players reduce pollution and advance, the world visually evolves—from a gritty, polluted settlement to a vibrant, clean eco-city—mirroring their progress.

---

## 4. Core Mechanics
*project-clicker* builds on traditional clicker game foundations while introducing strategic depth through its eco-focus and robot workforce. It's a 2d pixel game. Here are the key features:

- **Clicking**: Players manually click to gather basic resources (Wood, Stone, Food). Resources are limitless e.g. one sprite per resource in the world. Each click drops "bits" of "pixels" of such resource into the ground. Click again to move them, little by little to the "resource bank".
- **Automation**: Construct buildings like Farms, Quarries, and Lumber Mills to automate resource collection.  
- **Pollution System**: Resource gathering and construction generate pollution. Players must invest in green technologies (e.g., Solar Panels, Wind Turbines) to mitigate it, or risk stunting growth.  
- **Robot Workforce**: Players build robots with fixed, specialized roles:  
  - **Gatherers**: Collect resources from the environment.  
  - **Transporters**: Move resources to storage or processing areas.  
  - **Builders**: Construct and upgrade buildings.  
  - **Processors**: Refine raw resources into advanced materials (e.g., Wood into Planks).  
  - **Researchers**: Generate Research Points to unlock new technologies.  
- **Research Tree**: Use Research Points to unlock upgrades, new robot types, and advanced green tech.  
- **Mini-Games and Events**: Optional challenges (e.g., clearing a polluted zone) and random events (e.g., resource shortages or tech breakthroughs) add variety and replayability.  

These mechanics encourage players to strategize robot deployment and prioritize sustainability alongside expansion.

---

## 5. Progression and Phases
The game is designed to unfold over 20 hours, with distinct phases that evolve the gameplay experience:

- **Early Game (Hours 1-5)**:  
  - Objective: Establish a basic eco-village.  
  - Gameplay: Limited resources and robot options; players manually gather while building initial automation.  
  - Focus: Learn the pollution system and unlock basic green tech (e.g., Solar Panels).  

- **Mid Game (Hours 5-15)**:  
  - Objective: Expand the city and workforce.  
  - Gameplay: Unlock advanced robots (Processors, Researchers) and transport systems (e.g., Conveyor Belts, Drone Paths).  
  - Focus: Manage increasing pollution with more sophisticated solutions (e.g., Air Filters).  

- **Late Game (Hours 15-20)**:  
  - Objective: Achieve sustainability milestones (e.g., zero waste, carbon neutrality).  
  - Gameplay: Construct mega projects (e.g., Arcologies, Fusion Reactors) and deploy elite robots (e.g., Eco-Enforcers, Nano-Bots).  
  - Replayability: A prestige system resets progress with bonuses for new playthroughs.  

Progression is both visual (the world transforms) and mechanical (new systems unlock), keeping players engaged throughout.

---

## 6. Development Language and Tools
- **Language**: Lua  
- **Library**: Love 2d framework  
  - Purpose: Handles 2D graphics, input, audio, and window management.  
  - Benefits: Lightweight, fast, and ideal for pixel-art-based games.  
- **Steamworks SDK**:  
  - Purpose: Integrates Steam features like achievements, leaderboards, and cloud saves.  

### Why Lua with Love 2d framework?
- Offers high performance and granular control over game logic.  
- Seamlessly integrates with Steamworks SDK for Steam deployment.  
- Supports cross-platform development without unnecessary overhead (e.g., 3D rendering).  
- Easy to prototype and iterate

This tech stack keeps the project efficient and tailored to *project-clicker*’s 2D, performance-sensitive needs.

---

## 7. Implementation Plan
Here’s a step-by-step roadmap to bring *project-clicker* to life:

### Step 1: Core Game Loop
- Create a basic window with Love 2d  
- Implement event handling for mouse clicks and keyboard input.  
- Add a simple resource-gathering mechanic (click to collect Wood).  

### Step 2: Add Sprites and UI
- Design pixel art for resources, robots, and buildings (using tools like Aseprite).  
- Build a minimal UI with resource counters, a pollution bar, and action buttons.  

### Step 3: Robot System
- Code robot classes with fixed roles (Gatherer, Transporter, etc.).  
- Implement logic for assigning robots to tasks and managing their actions.  

### Step 4: Pollution and Green Tech
- Add a pollution tracker tied to resource gathering and building.  
- Introduce green tech buildings (e.g., Wind Turbines) that reduce pollution over time.  

### Step 5: Research and Upgrades
- Design a research tree with unlockable upgrades and tech.  
- Implement Research Points generation via Researcher robots.  

### Step 6: Steam Integration
- Download and integrate the Steamworks SDK.  
- Add Steam-specific features like achievements or leaderboards.  

### Step 7: Testing and Polish
- Test builds on Windows, Mac, and Linux for compatibility.  
- Refine visuals, balance mechanics (e.g., pollution rates), and fix bugs.  

### Step 8: Publish on Steam
- Register with Steam Direct.  
- Create a Steam store page with a trailer, screenshots, and description.  
- Upload the final builds and launch the game.  

---

## 8. Marketing and Community
- **Target Audience**: Clicker game fans, eco-conscious players, and solarpunk enthusiasts.  
- **Promotion**:  
  - Share dev logs on Twitter and Reddit (e.g., r/indiegames).  
  - Produce a trailer and pixel-art screenshots for Steam.  
  - Engage with indie game and eco-focused communities.  
- **Post-Launch**:  
  - Release updates with new robots, tech, or events.  
  - Incorporate player feedback for balance and quality-of-life improvements.  

---

## Final Summary
*project-clicker* combines the addictive simplicity of clicker games with a meaningful eco-twist, set in a visually striking solarpunk world. Its fixed-role robot system and pollution mechanics add strategic depth, while the 20-hour progression keeps players hooked. Built with Lua (Love 2d framework), the game will run efficiently on Steam across multiple platforms. This document outlines a clear path from concept to launch, ensuring a polished, engaging experience for players.
