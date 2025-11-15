


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



The error you're encountering is a known limitation with the "Run in Roblox" (RIR) plugin when working with Rojo projects that use Wally (or similar package managers like those integrated via Rokit) for dependency management. The `@DevPackages` alias in your `require` statements (e.g., `require("@DevPackages/Jest")`) is a filesystem-level shortcut created by Wally/Rokit during `wally install`. This alias resolves to your project's `Packages/Dev` folder in your local development environment, but RIR doesn't fully support these symbolic links or aliases during its sync process—it attempts to interpret them as literal Roblox paths, leading to the "unsupported alias" failure in the plugin's path resolution logic (around line 79-84 of the RIR main module).

This is especially common in testing setups like yours with `jest-lua`, where dev dependencies (e.g., `JestGlobals` and `Jest` from the `jsdotlua` registry) are required via `@DevPackages`. RIR is great for quick script execution in Studio but skips advanced Rojo features like alias resolution, which `rojo serve` handles seamlessly.

### Quick Fix: Use `rojo serve` for Testing
The standard workflow for Rojo + Wally/Rokit + `jest-lua` is to sync your project via `rojo serve` and run tests in Studio (or via CLI tools). This ensures aliases resolve correctly because Rojo builds the full instance hierarchy, including the `Packages` folder.

1. **Start Rojo Sync**:
   - In your project root (where `default.project.json` lives), run:
     ```
     rojo serve
     ```
   - Open your `.rbxl` or `.rbxlx` place file in Roblox Studio.
   - In Studio, go to **Plugins > Rojo > Connect** (or use the Rojo toolbar button). Your local files will sync to the game's `ReplicatedStorage` (or wherever your project.json maps `src` and `Packages`).

2. **Run Tests in Studio**:
   - With sync active, create or use your test entrypoint script (e.g., `scripts/run-tests.lua` in your project, synced to `ReplicatedStorage` or `ServerScriptService`).
   - Example `run-tests.lua` (adapt paths as needed; this assumes your tests are in `src` and packages in `Packages`):
     ```lua
     local ReplicatedStorage = game:GetService("ReplicatedStorage")
     local runCLI = require(ReplicatedStorage.Packages.Dev.Jest).runCLI  -- Uses resolved package path, no alias needed here

     local status, result = runCLI(ReplicatedStorage.Packages.Project, { verbose = true }, { ReplicatedStorage.Packages.Project }):awaitStatus()

     if status == "Rejected" then
         warn("Test failure:", result)
     elseif status == "Resolved" and (result.results.numFailedTestSuites > 0 or result.results.numFailedTests > 0) then
         warn("Tests failed!")
     else
         print("All tests passed!")
     end
     ```
   - Right-click the synced `run-tests` script in Explorer (e.g., under `ServerScriptService`) and select **Run** (or use Studio's **Script Analysis > Run Locally** if it's a LocalScript).
   - Check the **Output** window for test results. `jest-lua` will print passes/failures verbosely if `verbose = true`.

3. **Verify Project Setup** (if tests still fail on requires):
   - Ensure your `wally.toml` has dev deps like:
     ```toml
     [dev-dependencies]
     JestGlobals = "jsdotlua/jest-globals@0.22.0"
     Jest = "jsdotlua/jest@0.22.0"
     ```
   - Run `wally install` to populate `Packages`.
   - Your `default.project.json` should map `Packages` (full folder) and `src` (your project code/tests):
     ```json
     {
       "name": "YourProject",
       "tree": {
         "$className": "DataModel",
         "ReplicatedStorage": {
           "$className": "ReplicatedStorage",
           "$path": "src",
           "Packages": {
             "$path": "../Packages"
           }
         },
         "ServerScriptService": {
           "$path": "server"
         }
         // Add other services as needed
       }
     }
     ```
   - In test files (e.g., `src/specs/my-test.spec.lua`), use the resolved path:
     ```lua
     local JestGlobals = require(script.Parent.Parent.Packages.Dev.JestGlobals)
     local describe = JestGlobals.describe
     local it = JestGlobals.it
     local expect = JestGlobals.expect

     -- Your tests here
     ```
     Avoid `@DevPackages` in code that runs in Roblox—it's purely for local tooling like VS Code IntelliSense.

### Alternative: CLI Testing (No Studio Needed)
For faster iteration or CI/CD:
- Install `roblox-cli` (via `rokit install roblox-cli` or npm/yarn).
- Enable the `FFlagEnableLoadModule` fast flag in Studio (File > Settings > Script Editor > enable it) or via CLI flags.
- Run:
  ```
  roblox-cli run --load.model default.project.json --run scripts/run-tests.lua --fastFlags.overrides FFlagEnableLoadModule=true
  ```
- This spins up a headless Roblox instance, loads your Rojo project, and executes the test script. It handles Wally packages better than RIR.

### If You Must Use RIR
- Temporarily remove `@DevPackages` aliases from your test files and use relative paths (e.g., `require(ReplicatedStorage.Packages.Dev.Jest)` after manual sync).
- Or exclude `Packages` from RIR's sync scope in the plugin settings (if available—check RIR's config in Studio Plugins tab).
- But this is brittle; switch to `rojo serve` long-term.

If this doesn't resolve it, share your `default.project.json`, `wally.toml`, and the exact `require` line causing the error for more targeted help. For deeper troubleshooting, check the Rojo Discord or DevForum threads on Wally integration.




