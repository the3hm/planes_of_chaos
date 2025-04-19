# ExVenture Product Context

## Product Vision

ExVenture is a reimagined MUD platform designed for the modern web. It aims to preserve the narrative depth and community-driven essence of classic MUDs while removing technical friction for both players and worldbuilders. By combining real-time multiplayer mechanics with rich admin tooling and AI-enhanced NPC behavior, ExVenture lowers the barrier to entry and increases the potential for world customization and emergent storytelling.

The product is structured to:
- Provide immersive roleplay and gameplay via a browser-based interface
- Empower non-technical users to build persistent worlds
- Support large-scale, dynamic game states with real-time responsiveness
- Leverage behavior trees and modular data to enhance narrative depth

## Problem Space
Traditional MUDs face several challenges:
- Dated interfaces requiring special clients
- Complex setup processes
- Limited administrative tools
- Difficulty in world creation and management
- Steep learning curves for new players

## Feature Overview

ExVenture modernizes the MUD experience through:

- **Web-based Access**: No installation required; runs in any browser
- **LiveView Admin Tools**: Zones, NPCs, items, and quests editable in real time
- **Modular Game Engine**: A forked Kalevala backend supports plug-and-play behaviors and data-driven world logic
- **Behavior Trees**: NPCs can be programmed with modular AI logic for dynamic responses
- **Onboarding & Tutorials**: New players are guided through early gameplay
- **Admin Dashboard**: Visual tools for creating, editing, and testing world elements

## Solution
ExVenture modernizes the MUD experience by:
- Providing a web-based interface accessible from any browser
- Streamlining the onboarding process
- Offering powerful admin tools for world building
- Creating an intuitive player experience
- Maintaining the depth of traditional MUDs

## User Experience Goals

### Players
1. Immediate Engagement
   - Quick registration process
   - Intuitive character creation
   - Clear introduction to game mechanics
   - Accessible command system

2. Immersive Gameplay
   - Rich text descriptions
   - Responsive interactions
   - Clear feedback
   - Contextual help system
   - Real-time feedback via WebSockets
   - NPCs driven by unique behavior trees
   - Environment reacts dynamically to player actions

3. Social Interaction
   - Multiple communication channels
   - Emote system
   - Group activities
   - Community features

### Administrators
1. World Building
   - Visual room/zone editor
   - NPC creation tools
   - Item management
   - Quest design system

2. Game Management
   - Player monitoring
   - System statistics
   - Moderation tools
   - Configuration controls

3. Content Creation
   - Rich text editor
   - Template system
   - Asset management
   - Version control
   - Drag-and-drop behavior tree editor (planned)
   - Live previews of NPC logic and interactions
   - Integrated documentation and in-editor tooltips

## Core User Flows

### Player Experience
1. Discovery & Onboarding
   - Landing page introduction
   - Account creation
   - Character creation
   - Tutorial zone

2. Regular Gameplay
   - World exploration
   - Character advancement
   - Item collection/management
   - Social interaction
   - Combat/challenges

3. Community Engagement
   - Chat channels
   - Group activities
   - Trading/economy
   - Character relationships

### Admin Experience
1. World Creation
   - Zone planning
   - Room creation/linking
   - NPC placement
   - Item distribution
   - Behavior tree wiring (via modular node editor)
   - NPC AI preview tools (for testing reaction trees)

2. Maintenance
   - Player management
   - System monitoring
   - Content updates
   - Bug fixes

3. Community Management
   - Event planning
   - Moderation
   - Player support
   - Analytics review

## Success Metrics
1. Player Engagement
   - Daily active users
   - Session duration
   - Return rate
   - Social interaction levels

2. Admin Efficiency
   - Content creation speed
   - Issue resolution time
   - System stability
   - Feature utilization

3. Community Health
   - Player retention
   - New player conversion
   - Community participation
   - Feedback quality

## Design Principles

- Minimize friction for new users (players and admins)
- Real-time responsiveness over reload-based UIs
- Admin interfaces must be intuitive and visually consistent (Petal + Tailwind)
- Player actions must be interpreted by the game engine (Kantele), not the frontend
- Every feature should support extensibility: schema-first, modular, and live-editable

## Future Directions

- A drag-and-drop AI editor for authoring behavior trees
- Expanded faction and guild systems with economy support
- Scene-based storytelling via point-of-interest systems on a map
- Modular quest builder with conditions and outcomes
- Stripe integration for account monetization
- OAuth support for account systems (planned via Ueberauth)



This context guides all product decisions to ensure alignment with user needs and project goals.
