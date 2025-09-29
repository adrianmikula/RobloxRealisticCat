


-- I want to create automated tests for the most important code modules in the realistic cat game. While complete code coverage might be impossible, I want to aim for basic coverage of the most critical code paths, so I can easily verify that the game still works without needing to actually log in and play it every time the code changes. 


-- The testing focus should be on small, self-contained unit tests so they can targe ecific code functions and they are easy to maintain. 


-- We should use a popular Roblox testing framework like TestService or TestEZ.


-- Each time we build a new module, we should write test for it and get them working before advancing to work on the next module.
-- So that at any point in time, we have a working game we can try out and play.
-- '

We will also have a small set of performance tests which measure how well the game scales when we have a large number of cats, players, or both.


