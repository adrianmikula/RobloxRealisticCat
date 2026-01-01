# Loading Screen System

This document explains the loading screen system that prevents game freezes during startup.

## Overview

The loading screen system provides:
- **Visual feedback** during game initialization
- **Progress tracking** for loading operations
- **Non-blocking initialization** to prevent freezes
- **Smooth fade-out** when loading completes

## How It Works

### Client-Side Loading

1. **Immediate Display**: Loading screen appears immediately when the client script starts
2. **Async Initialization**: All initialization tasks run asynchronously using `task.spawn()`
3. **Progress Updates**: Progress is updated as different systems initialize
4. **Automatic Hide**: Loading screen fades out when initialization completes

### Progress Stages

The loading screen tracks progress through these stages:

1. **0-5%**: Loading game scripts
2. **5-10%**: Initializing game systems
3. **10-20%**: Starting Knit framework
4. **20-40%**: Connecting to server
5. **40-60%**: Loading game content
6. **60-80%**: Loading cats (with per-cat progress)
7. **80-95%**: Finalizing
8. **95-100%**: Ready!

## Implementation

### Loading Screen Component

The `LoadingScreen` class (`src/client/loading-screen.ts`) provides:

- `Initialize()`: Creates and shows the loading screen UI
- `SetProgress(progress, message)`: Updates progress (0-1) and message
- `Hide()`: Fades out and removes the loading screen
- `IsVisible()`: Checks if loading screen is currently visible
- `GetProgress()`: Gets current progress (0-1)

### Integration Points

1. **Main Client** (`src/client/main.client.ts`):
   - Shows loading screen immediately
   - Runs Knit initialization asynchronously
   - Updates progress throughout initialization

2. **Cat Controller** (`src/client/cat-controller.ts`):
   - Updates progress while loading existing cats
   - Shows per-cat loading progress

3. **Server** (`src/server/main.server.ts`):
   - Runs Knit initialization asynchronously
   - Prevents server-side blocking

## Customization

### Changing Progress Messages

Edit `src/client/main.client.ts` to customize progress messages:

```typescript
LoadingScreen.SetProgress(0.5, "Your custom message here");
```

### Adjusting Progress Stages

Modify the progress values in:
- `src/client/main.client.ts` - Main initialization stages
- `src/client/cat-controller.ts` - Cat loading progress

### Styling the Loading Screen

Edit `src/client/loading-screen.ts` in the `Initialize()` method to customize:
- Colors (background, progress bar, text)
- Size and position
- Fonts and text sizes
- Animation duration

## Best Practices

1. **Update Progress Frequently**: Show progress updates for long operations
2. **Use Descriptive Messages**: Tell users what's happening
3. **Don't Block**: Always use `task.spawn()` for long operations
4. **Handle Errors**: Show error messages if initialization fails
5. **Test Loading Times**: Ensure loading doesn't take too long

## Troubleshooting

### Loading Screen Doesn't Appear

- Check that `LoadingScreen.Initialize()` is called early
- Verify the script is running on the client
- Check for errors in the Output window

### Loading Screen Stays Visible

- Check that `LoadingScreen.Hide()` is being called
- Verify initialization completes successfully
- Check for errors preventing completion

### Progress Not Updating

- Ensure `LoadingScreen.SetProgress()` is being called
- Check that progress values are between 0 and 1
- Verify the loading screen was initialized

### Game Still Freezes

- Check for synchronous operations that aren't wrapped in `task.spawn()`
- Look for blocking operations in server initialization
- Verify all imports are fast (no heavy computation)

## Performance Considerations

- **Async Operations**: All initialization runs asynchronously
- **Progress Updates**: Updates are throttled to prevent UI lag
- **Resource Loading**: Models and assets load asynchronously
- **Server Sync**: Server initialization doesn't block client

## Future Enhancements

Potential improvements:
- More granular progress tracking
- Loading tips/hints during wait
- Estimated time remaining
- Background asset preloading
- Configurable minimum loading time

