const { app, BrowserWindow, Menu, ipcMain } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 450,
        height: 600,
        minWidth: 360,
        minHeight: 500,
        icon: path.join(__dirname, 'resources', 'icon.ico'),
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false
        },
        title: '2048 Game'
    });

    mainWindow.loadFile(path.join(__dirname, '../build/web/index.html'));

    const menu = Menu.buildFromTemplate([
        {
            label: '游戏',
            submenu: [
                { 
                    label: '新游戏', 
                    accelerator: 'Ctrl+N',
                    click: () => mainWindow.webContents.send('newGame') 
                },
                { 
                    label: '重置', 
                    accelerator: 'Ctrl+R',
                    click: () => mainWindow.webContents.send('resetGame') 
                },
                { type: 'separator' },
                { 
                    label: '退出', 
                    accelerator: 'Ctrl+Q',
                    click: () => app.quit() 
                }
            ]
        },
        {
            label: '帮助',
            submenu: [
                { 
                    label: '关于',
                    click: () => mainWindow.webContents.send('showAbout') 
                }
            ]
        }
    ]);
    Menu.setApplicationMenu(menu);

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

ipcMain.on('minimize', () => {
    mainWindow.minimize();
});

ipcMain.on('maximize', () => {
    if (mainWindow.isMaximized()) {
        mainWindow.unmaximize();
    } else {
        mainWindow.maximize();
    }
});

ipcMain.on('close', () => {
    app.quit();
});