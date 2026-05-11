class Game2048 {
    constructor() {
        this.gridSize = 4;
        this.grid = [];
        this.score = 0;
        this.bestScore = this.loadBestScore();
        this.hasWon = false;
        this.isGameOver = false;
        this.tileIdCounter = 0;
        
        this.setupElements();
        this.setupEventListeners();
        this.loadSettings();
        this.initGame();
    }

    setupElements() {
        this.scoreElement = document.getElementById('score');
        this.bestScoreElement = document.getElementById('bestScore');
        this.gridContainer = document.getElementById('gridContainer');
        this.tileContainer = document.getElementById('tileContainer');
        this.newGameBtn = document.getElementById('newGameBtn');
        this.settingsBtn = document.getElementById('settingsBtn');
        this.levelBtn = document.getElementById('levelBtn');
        
        this.modalOverlay = document.getElementById('modalOverlay');
        this.modalTitle = document.getElementById('modalTitle');
        this.modalMessage = document.getElementById('modalMessage');
        this.modalBtn1 = document.getElementById('modalBtn1');
        this.modalBtn2 = document.getElementById('modalBtn2');
        
        this.settingsOverlay = document.getElementById('settingsOverlay');
        this.darkModeToggle = document.getElementById('darkModeToggle');
        this.soundToggle = document.getElementById('soundToggle');
        this.settingsCloseBtn = document.getElementById('settingsCloseBtn');
        
        this.levelOverlay = document.getElementById('levelOverlay');
        this.levelCloseBtn = document.getElementById('levelCloseBtn');
        this.customSize = document.getElementById('customSize');
        this.customSizeDisplay = document.getElementById('customSizeDisplay');
        this.customStartBtn = document.getElementById('customStartBtn');
    }

    setupEventListeners() {
        this.newGameBtn.addEventListener('click', () => this.initGame());
        this.settingsBtn.addEventListener('click', () => this.showSettings());
        this.levelBtn.addEventListener('click', () => this.showLevelSelect());
        
        document.addEventListener('keydown', (e) => this.handleKeyDown(e));
        
        this.settingsCloseBtn.addEventListener('click', () => this.hideSettings());
        this.darkModeToggle.addEventListener('change', (e) => this.toggleDarkMode(e.target.checked));
        this.soundToggle.addEventListener('change', (e) => this.toggleSound(e.target.checked));
        
        this.levelCloseBtn.addEventListener('click', () => this.hideLevelSelect());
        this.customSize.addEventListener('input', (e) => this.updateCustomSize(e.target.value));
        this.customStartBtn.addEventListener('click', () => this.startCustomLevel());
        
        document.querySelectorAll('.level-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.selectLevel(parseInt(e.currentTarget.dataset.size)));
        });
        
        this.setupTouchEvents();
    }

    setupTouchEvents() {
        let startX, startY;
        
        document.addEventListener('touchstart', (e) => {
            startX = e.touches[0].clientX;
            startY = e.touches[0].clientY;
        }, { passive: true });
        
        document.addEventListener('touchend', (e) => {
            const endX = e.changedTouches[0].clientX;
            const endY = e.changedTouches[0].clientY;
            const dx = endX - startX;
            const dy = endY - startY;
            const minSwipe = 50;
            
            if (Math.abs(dx) > Math.abs(dy)) {
                if (Math.abs(dx) > minSwipe) {
                    this.move(dx > 0 ? 'right' : 'left');
                }
            } else {
                if (Math.abs(dy) > minSwipe) {
                    this.move(dy > 0 ? 'down' : 'up');
                }
            }
        }, { passive: true });
    }

    handleKeyDown(e) {
        if (this.isGameOver && !this.hasWon) return;
        
        switch (e.key) {
            case 'ArrowUp':
            case 'w':
            case 'W':
                e.preventDefault();
                this.move('up');
                break;
            case 'ArrowDown':
            case 's':
            case 'S':
                e.preventDefault();
                this.move('down');
                break;
            case 'ArrowLeft':
            case 'a':
            case 'A':
                e.preventDefault();
                this.move('left');
                break;
            case 'ArrowRight':
            case 'd':
            case 'D':
                e.preventDefault();
                this.move('right');
                break;
        }
    }

    initGame() {
        this.grid = Array(this.gridSize).fill(null).map(() => Array(this.gridSize).fill(0));
        this.score = 0;
        this.hasWon = false;
        this.isGameOver = false;
        this.tileIdCounter = 0;
        
        this.addRandomTile();
        this.addRandomTile();
        this.updateUI();
    }

    addRandomTile() {
        const emptyCells = [];
        for (let i = 0; i < this.gridSize; i++) {
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] === 0) {
                    emptyCells.push({ row: i, col: j });
                }
            }
        }
        
        if (emptyCells.length === 0) return null;
        
        const randomCell = emptyCells[Math.floor(Math.random() * emptyCells.length)];
        const value = Math.random() < 0.9 ? 2 : 4;
        this.grid[randomCell.row][randomCell.col] = value;
        
        this.addTileElement(randomCell.row, randomCell.col, value);
        return { row: randomCell.row, col: randomCell.col, value };
    }

    addTileElement(row, col, value) {
        const tile = document.createElement('div');
        tile.id = `tile-${++this.tileIdCounter}`;
        tile.className = `tile tile-${value}`;
        tile.textContent = value;
        
        const cellSize = this.getCellSize();
        const gap = 10;
        const offset = 15;
        
        tile.style.width = `${cellSize}px`;
        tile.style.height = `${cellSize}px`;
        tile.style.left = `${offset + col * (cellSize + gap)}px`;
        tile.style.top = `${offset + row * (cellSize + gap)}px`;
        
        if (value >= 1000) {
            tile.style.fontSize = `${cellSize * 0.35}px`;
        } else if (value >= 100) {
            tile.style.fontSize = `${cellSize * 0.45}px`;
        } else {
            tile.style.fontSize = `${cellSize * 0.55}px`;
        }
        
        this.tileContainer.appendChild(tile);
    }

    getCellSize() {
        const boardSize = Math.min(400, window.innerWidth - 40);
        const gap = 10;
        return (boardSize - 30 - (this.gridSize - 1) * gap) / this.gridSize;
    }

    move(direction) {
        if (this.isGameOver) return;
        
        let moved = false;
        const oldGrid = this.grid.map(row => [...row]);
        
        switch (direction) {
            case 'up':
                moved = this.moveUp();
                break;
            case 'down':
                moved = this.moveDown();
                break;
            case 'left':
                moved = this.moveLeft();
                break;
            case 'right':
                moved = this.moveRight();
                break;
        }
        
        if (moved) {
            this.playSound('move');
            setTimeout(() => {
                this.addRandomTile();
                this.updateUI();
                
                if (this.checkWin()) {
                    this.hasWon = true;
                    this.playSound('win');
                    this.showWinModal();
                } else if (this.checkGameOver()) {
                    this.isGameOver = true;
                    this.playSound('lose');
                    this.showGameOverModal();
                }
            }, 150);
        }
    }

    moveLeft() {
        let moved = false;
        
        for (let i = 0; i < this.gridSize; i++) {
            let row = this.grid[i].filter(val => val !== 0);
            
            for (let j = 0; j < row.length - 1; j++) {
                if (row[j] === row[j + 1]) {
                    row[j] *= 2;
                    this.score += row[j];
                    this.removeTileAt(i, j + 1);
                    row.splice(j + 1, 1);
                    this.highlightTile(i, j);
                }
            }
            
            while (row.length < this.gridSize) {
                row.push(0);
            }
            
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] !== row[j]) {
                    moved = true;
                    this.grid[i][j] = row[j];
                }
            }
        }
        
        return moved;
    }

    moveRight() {
        let moved = false;
        
        for (let i = 0; i < this.gridSize; i++) {
            let row = this.grid[i].filter(val => val !== 0);
            
            for (let j = row.length - 1; j > 0; j--) {
                if (row[j] === row[j - 1]) {
                    row[j] *= 2;
                    this.score += row[j];
                    this.removeTileAt(i, j - 1);
                    row.splice(j - 1, 1);
                    this.highlightTile(i, j);
                }
            }
            
            while (row.length < this.gridSize) {
                row.unshift(0);
            }
            
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] !== row[j]) {
                    moved = true;
                    this.grid[i][j] = row[j];
                }
            }
        }
        
        return moved;
    }

    moveUp() {
        let moved = false;
        
        for (let j = 0; j < this.gridSize; j++) {
            let col = [];
            for (let i = 0; i < this.gridSize; i++) {
                if (this.grid[i][j] !== 0) {
                    col.push(this.grid[i][j]);
                }
            }
            
            for (let i = 0; i < col.length - 1; i++) {
                if (col[i] === col[i + 1]) {
                    col[i] *= 2;
                    this.score += col[i];
                    this.removeTileAt(i + 1, j);
                    col.splice(i + 1, 1);
                    this.highlightTile(i, j);
                }
            }
            
            while (col.length < this.gridSize) {
                col.push(0);
            }
            
            for (let i = 0; i < this.gridSize; i++) {
                if (this.grid[i][j] !== col[i]) {
                    moved = true;
                    this.grid[i][j] = col[i];
                }
            }
        }
        
        return moved;
    }

    moveDown() {
        let moved = false;
        
        for (let j = 0; j < this.gridSize; j++) {
            let col = [];
            for (let i = 0; i < this.gridSize; i++) {
                if (this.grid[i][j] !== 0) {
                    col.push(this.grid[i][j]);
                }
            }
            
            for (let i = col.length - 1; i > 0; i--) {
                if (col[i] === col[i - 1]) {
                    col[i] *= 2;
                    this.score += col[i];
                    this.removeTileAt(i - 1, j);
                    col.splice(i - 1, 1);
                    this.highlightTile(i, j);
                }
            }
            
            while (col.length < this.gridSize) {
                col.unshift(0);
            }
            
            for (let i = 0; i < this.gridSize; i++) {
                if (this.grid[i][j] !== col[i]) {
                    moved = true;
                    this.grid[i][j] = col[i];
                }
            }
        }
        
        return moved;
    }

    removeTileAt(row, col) {
        const cellSize = this.getCellSize();
        const gap = 10;
        const offset = 15;
        const tiles = this.tileContainer.children;
        
        for (let i = tiles.length - 1; i >= 0; i--) {
            const tile = tiles[i];
            const tileLeft = parseFloat(tile.style.left);
            const tileTop = parseFloat(tile.style.top);
            
            const expectedLeft = offset + col * (cellSize + gap);
            const expectedTop = offset + row * (cellSize + gap);
            
            if (Math.abs(tileLeft - expectedLeft) < 5 && Math.abs(tileTop - expectedTop) < 5) {
                tile.remove();
                break;
            }
        }
    }

    highlightTile(row, col) {
        const cellSize = this.getCellSize();
        const gap = 10;
        const offset = 15;
        const tiles = this.tileContainer.children;
        
        for (let i = tiles.length - 1; i >= 0; i--) {
            const tile = tiles[i];
            const tileLeft = parseFloat(tile.style.left);
            const tileTop = parseFloat(tile.style.top);
            
            const expectedLeft = offset + col * (cellSize + gap);
            const expectedTop = offset + row * (cellSize + gap);
            
            if (Math.abs(tileLeft - expectedLeft) < 5 && Math.abs(tileTop - expectedTop) < 5) {
                tile.classList.add('merged');
                setTimeout(() => tile.classList.remove('merged'), 250);
                break;
            }
        }
    }

    updateUI() {
        this.scoreElement.textContent = this.score;
        this.bestScoreElement.textContent = Math.max(this.score, this.bestScore);
        
        const tiles = this.tileContainer.children;
        const cellSize = this.getCellSize();
        const gap = 10;
        const offset = 15;
        
        for (let i = tiles.length - 1; i >= 0; i--) {
            tiles[i].remove();
        }
        
        for (let i = 0; i < this.gridSize; i++) {
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] !== 0) {
                    this.addTileElement(i, j, this.grid[i][j]);
                }
            }
        }
        
        this.updateGridDisplay();
    }

    updateGridDisplay() {
        const cellSize = this.getCellSize();
        
        this.gridContainer.innerHTML = '';
        this.gridContainer.style.gridTemplateColumns = `repeat(${this.gridSize}, ${cellSize}px)`;
        this.gridContainer.style.gridTemplateRows = `repeat(${this.gridSize}, ${cellSize}px)`;
        
        for (let i = 0; i < this.gridSize * this.gridSize; i++) {
            const cell = document.createElement('div');
            cell.className = 'grid-cell';
            cell.style.width = `${cellSize}px`;
            cell.style.height = `${cellSize}px`;
            this.gridContainer.appendChild(cell);
        }
        
        this.tileContainer.style.gridTemplateColumns = `repeat(${this.gridSize}, ${cellSize}px)`;
        this.tileContainer.style.gridTemplateRows = `repeat(${this.gridSize}, ${cellSize}px)`;
    }

    checkWin() {
        for (let i = 0; i < this.gridSize; i++) {
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] === 2048) {
                    return true;
                }
            }
        }
        return false;
    }

    checkGameOver() {
        for (let i = 0; i < this.gridSize; i++) {
            for (let j = 0; j < this.gridSize; j++) {
                if (this.grid[i][j] === 0) return false;
                if (j < this.gridSize - 1 && this.grid[i][j] === this.grid[i][j + 1]) return false;
                if (i < this.gridSize - 1 && this.grid[i][j] === this.grid[i + 1][j]) return false;
            }
        }
        return true;
    }

    showWinModal() {
        this.modalTitle.textContent = '🎉 恭喜！';
        this.modalMessage.textContent = `你达到了2048！\n当前分数: ${this.score}`;
        this.modalBtn1.textContent = '继续游戏';
        this.modalBtn2.textContent = '新游戏';
        this.modalBtn2.style.display = 'inline-block';
        
        this.modalBtn1.onclick = () => {
            this.hideModal();
        };
        
        this.modalBtn2.onclick = () => {
            this.hideModal();
            this.initGame();
        };
        
        this.modalOverlay.classList.add('show');
    }

    showGameOverModal() {
        this.modalTitle.textContent = '游戏结束';
        this.modalMessage.textContent = `最终分数: ${this.score}`;
        this.modalBtn1.textContent = '再来一局';
        this.modalBtn2.style.display = 'none';
        
        this.modalBtn1.onclick = () => {
            this.hideModal();
            this.initGame();
        };
        
        this.modalOverlay.classList.add('show');
    }

    hideModal() {
        this.modalOverlay.classList.remove('show');
    }

    showSettings() {
        this.settingsOverlay.classList.add('show');
    }

    hideSettings() {
        this.settingsOverlay.classList.remove('show');
    }

    showLevelSelect() {
        this.levelOverlay.classList.add('show');
    }

    hideLevelSelect() {
        this.levelOverlay.classList.remove('show');
    }

    updateCustomSize(value) {
        this.customSizeDisplay.textContent = `${value}x${value}`;
    }

    startCustomLevel() {
        const size = parseInt(this.customSize.value);
        this.selectLevel(size);
    }

    selectLevel(size) {
        this.gridSize = size;
        this.hideLevelSelect();
        this.updateGridDisplay();
        this.saveGridSize(size);
        this.initGame();
    }

    toggleDarkMode(enabled) {
        document.body.classList.toggle('dark', enabled);
        localStorage.setItem('darkMode', enabled.toString());
    }

    toggleSound(enabled) {
        localStorage.setItem('soundEnabled', enabled.toString());
    }

    playSound(type) {
        const enabled = localStorage.getItem('soundEnabled') !== 'false';
        if (!enabled) return;
        
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        switch (type) {
            case 'move':
                oscillator.frequency.value = 400;
                gainNode.gain.value = 0.1;
                oscillator.start();
                oscillator.stop(audioContext.currentTime + 0.05);
                break;
            case 'win':
                oscillator.frequency.value = 800;
                gainNode.gain.value = 0.1;
                oscillator.start();
                oscillator.stop(audioContext.currentTime + 0.3);
                break;
            case 'lose':
                oscillator.frequency.value = 200;
                gainNode.gain.value = 0.1;
                oscillator.start();
                oscillator.stop(audioContext.currentTime + 0.2);
                break;
        }
    }

    loadBestScore() {
        const saved = localStorage.getItem(`bestScore_${this.gridSize}`);
        return saved ? parseInt(saved) : 0;
    }

    saveBestScore() {
        if (this.score > this.bestScore) {
            this.bestScore = this.score;
            localStorage.setItem(`bestScore_${this.gridSize}`, this.score.toString());
        }
    }

    saveGridSize(size) {
        localStorage.setItem('gridSize', size.toString());
    }

    loadGridSize() {
        const saved = localStorage.getItem('gridSize');
        return saved ? parseInt(saved) : 4;
    }

    loadSettings() {
        const darkMode = localStorage.getItem('darkMode') === 'true';
        const soundEnabled = localStorage.getItem('soundEnabled') !== 'false';
        const gridSize = this.loadGridSize();
        
        this.darkModeToggle.checked = darkMode;
        this.soundToggle.checked = soundEnabled;
        this.gridSize = gridSize;
        this.customSize.value = gridSize;
        this.customSizeDisplay.textContent = `${gridSize}x${gridSize}`;
        
        if (darkMode) {
            document.body.classList.add('dark');
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new Game2048();
});