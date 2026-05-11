const { ipcRenderer, contextBridge } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    onNewGame: (callback) => ipcRenderer.on('newGame', callback),
    onResetGame: (callback) => ipcRenderer.on('resetGame', callback),
    onShowAbout: (callback) => ipcRenderer.on('showAbout', callback),
    minimize: () => ipcRenderer.send('minimize'),
    maximize: () => ipcRenderer.send('maximize'),
    close: () => ipcRenderer.send('close'),
    sendNewGame: () => ipcRenderer.send('newGame'),
    sendResetGame: () => ipcRenderer.send('resetGame')
});