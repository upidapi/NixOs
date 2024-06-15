const main = '/tmp/ags/main.js';

try {
    // @ts-ignore
    await Utils.execAsync([
        'bun', 'build', `${App.configDir}/main.ts`,
        '--outfile', main,
        '--external', 'resource://*',
        '--external', 'gi://*',
        '--external', 'file://*',
    ]);
    // @ts-ignore
    await import(`file://${main}`);
} catch (error) {
    console.error(error);
    App.quit();
}
