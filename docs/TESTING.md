


## Testing Goals

-- I want to create automated tests for the most important code modules in the realistic cat game. While complete code coverage might be impossible, I want to aim for basic coverage of the most critical code paths, so I can easily verify that the game still works without needing to actually log in and play it every time the code changes. 


-- The testing focus should be on small, self-contained unit tests so they can targe ecific code functions and they are easy to maintain. 


-- We should use a popular Roblox testing framework like TestService or TestEZ.


-- Each time we build a new module, we should write test for it and get them working before advancing to work on the next module.
-- So that at any point in time, we have a working game we can try out and play.
-- '

We will also have a small set of performance tests which measure how well the game scales when we have a large number of cats, players, or both.





### Getting TestEZ Working via CLI Only

TestEZ remains a solid, Roblox-maintained choice in 2025—it's actively used internally by Roblox for testing core scripts, plugins, and libraries like Roact. The core library hasn't seen major overhauls since around 2020, but it's stable and recommended in recent dev discussions (e.g., a April 2025 DevForum post urging more automated testing with it). The Studio plugin issues you're seeing are common complaints, but you *can* run it via CLI without Studio or the plugin. However, it requires Roblox's Open Cloud API for headless execution, as TestEZ relies on the Roblox engine environment (e.g., globals like `workspace`, `game`, and Luau-specific behaviors). This isn't purely local—it's cloud-based—but it's scriptable and integrates well with Rojo for fast builds.

#### Setup for CLI-Only TestEZ with Rojo
1. **Prerequisites**:
   - Rojo installed (via `npm install -g @rojo-rbx/rojo` or Cargo).
   - Wally for dependencies (install via `cargo install wally`).
   - Roblox Open Cloud API key: Create one in Creator Dashboard with `universe.places:write` and `universe.place.luau-execution-session:write` scopes for a test place/universe.
   - A separate "test place" in Roblox (not your main game) for running executions—keep it minimal (e.g., just a ServerScriptService for tests).

2. **Project Structure with Rojo**:
   - Use Rojo's `init` to set up your project: `rojo init my-tests`.
   - In `wally.toml`, add TestEZ as a dev dependency:
     ```
     [dependencies]
     TestEZ = "1.5.1"  # Latest as of 2025
     ```
     Run `wally install` to fetch it into `Packages/`.
   - Write tests in `.spec.lua` files (BDD-style, e.g., `describe("MyModule", function() ... end)`). Place them under a `spec/` folder synced to ServerScriptService via your `default.project.json`.
   - Example test file (`spec/MyModule.spec.lua`):
     ```lua
     local TestEZ = require(game.ServerScriptService.TestEZ)
     local MyModule = require(game.ServerScriptService.MyModule)

     return function()
         local tests = TestEZ.TestBootstrap:run({
             MyModule = script.Parent.MyModule,
         }, script)
         TestEZ.TestRunner:run(tests)
     end
     ```

3. **CLI Workflow (Local Scripting)**:
   - **Build & Sync**: Use Rojo to generate an RBXL: `rojo build default.project.json -o tests.rbxl`. This bundles your code/tests.
   - **Upload & Execute**: Use Roblox's Open Cloud API via a script (e.g., Python or Node.js CLI tool). Roblox provides a demo repo for this: [place-ci-cd-demo](https://github.com/Roblox/place-ci-cd-demo). Key steps:
     - Upload the RBXL to your test place: Use the API endpoint `/v1/universes/{universeId}/places/{placeId}` with your API key.
     - Run the test: POST to `/v1/universes/{universeId}/places/{placeId}/luau-execution-sessions` with a payload specifying the script to execute (e.g., your bootstrap script). It returns stdout/stderr, including TestEZ reports.
     - Example Python snippet (adapt from the demo):
       ```python
       import requests

       API_KEY = "your-api-key"
       UNIVERSE_ID = 123456  # Test universe
       PLACE_ID = 789012    # Test place
       headers = {"x-api-key": API_KEY, "Content-Type": "application/json"}

       # Upload RBXL (multipart)
       with open("tests.rbxl", "rb") as f:
           response = requests.post(f"https://apis.roblox.com/universes/v1/universes/{UNIVERSE_ID}/places/{PLACE_ID}", headers=headers, files={"file": f})

       # Execute
       payload = {"entrypoint": "ServerScriptService.Bootstrap"}  # Path to your TestEZ runner
       response = requests.post(f"https://engine.apis.roblox.com/v1/universes/{UNIVERSE_ID}/places/{PLACE_ID}/luau-execution-sessions", headers=headers, json=payload)
       print(response.json()["output"])  # Test results
       ```
     - Chain this in a bash script or npm script: `rojo build && python run_tests.py`.
   - **Output**: TestEZ formats results as TAP (Test Anything Protocol), easy to parse for CI or console.

4. **Pros/Cons for Your Workflow**:
   - **Quick Iteration?** Decent (~10-30s per run with good internet), but network latency beats pure local. Great for post-AI-change verification.
   - **AI Tool Integration**: Pipe results to your AI (e.g., via JSON parsing) for feedback loops.
   - **Limitations**: Tests needing client-side or physics sim need workarounds (e.g., mock `RunService`). Full engine access, but no local debugging.

This setup is popular for CI/CD in 2025 (e.g., GitHub Actions workflows with Rojo + Wally + TestEZ). For local-only, see alternatives below.

### Newer/Better Alternatives in 2025
TestEZ is battle-tested but feels dated for CLI-heavy flows. In 2025, the ecosystem has shifted toward standalone runtimes for faster local testing, especially with AI-driven iteration. Top recs prioritize local CLI execution, Rojo/Wally integration, and minimal setup. Focus on unit tests (pure logic/modules); integration tests may still need Open Cloud.

| Framework/Runtime | Description | CLI/Local? | Rojo/VSCode Fit | Pros | Cons | Setup Time |
|-------------------|-------------|------------|-----------------|------|------|------------|
| **Lune + Jest-Lua** (Recommended for You) | Lune: Standalone Luau runtime (~5MB binary, Rust-based). Jest-Lua: Port of Jest for Lua/Luau (community fork of Roblox's internal Jest-Roblox). | Yes (pure local CLI, no network). Run `lune run test.lua`. | Excellent—Wally for deps, Rojo for project sync. VSCode extension available. | Fast (~1-5s runs), async APIs, task scheduler mimics Roblox. Popular for Roblox unit/integration tests in 2025 (e.g., CI/CD pipelines). Decouples from Roblox engine. | Needs mocks for Roblox globals (e.g., `workspace`). Jest-Lua still maturing for non-Roblox envs. | 10-15 min |
| **Lune + Busted** | Busted: Mature Lua BDD testing lib (like TestEZ but lighter). | Yes (local CLI via `lune`). | Good—Wally install, Rojo sync. | Simple, no bloat. Full async support in Lune. Great for pure functions. | Less "delightful" than Jest; manual mocking. | 5 min |
| **Open Cloud + Jest-Roblox** | Roblox's Jest port for Luau (BDD + snapshots). | CLI via API scripts (like TestEZ). | Strong Rojo integration. | Roblox-official, module mocking built-in. Used internally. | Cloud-only, same latency as TestEZ. | 15 min (reuse TestEZ scripts) |
| **Luau CLI (Standalone)** | Roblox's official Luau binary for linting/running scripts. | Yes (local: `luau script.lua`). | Basic—pair with simple asserts. | Zero deps, built-in type checking (`luau-analyze`). | No full testing framework; DIY asserts. | 2 min |

#### Quick Start: Lune + Jest-Lua (Best for Fast AI Iteration)
1. **Install Lune**: Download binary from [lune.sh](https://lune.sh) (Windows/Mac/Linux). Add to PATH.
2. **Project**: In Rojo project, `wally add jsdotlua/jest-lua@1.0.0 --dev` (latest community version).
3. **Test File** (`test.spec.lua`):
   ```lua
   local JestGlobals = require("Packages.JestGlobals")
   local describe = JestGlobals.describe
   local expect = JestGlobals.expect
   local it = JestGlobals.it

   describe("MyModule", function()
       it("should add numbers", function()
           local result = require("src/MyModule").add(2, 3)
           expect(result).toBe(5)
       end)
   end)
   ```
4. **Run**: `lune run test.spec.lua` (or `lune test` if configured). Outputs JUnit/TAP for parsing.
5. **With Rojo/AI**: Sync changes with `rojo serve`, edit in VSCode, run Lune CLI after AI suggestions. For Roblox APIs, use Lune's built-in `rbx` lib or community mocks.

Lune shines for your use case—it's designed for Roblox devs doing local testing without Studio, and 2025 adoption is high for quick loops. If your tests are engine-heavy, stick with Open Cloud + TestEZ/Jest-Roblox.

If you share more on your code (e.g., heavy API use?), I can refine this.


