// In-memory fallback for incognito mode or when localStorage is unavailable
const memoryStorage = new Map();

export default class gameStorage {
  static isCrazyGames() {
    return window.inCrazyGames;
  }

  static isLocalStorageAvailable() {
    try {
      const test = '__localStorage_test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      return true;
    } catch (e) {
      return false;
    }
  }

  static setItem(key, value) {
    // console.log('setItem', key, value );
    try {
      if (gameStorage.isCrazyGames()) {
        window.CrazyGames.SDK.data.setItem(key, value);
      } else if (gameStorage.isLocalStorageAvailable()) {
        window.localStorage.setItem(key, value);
      } else {
        // Fallback to memory storage (incognito mode)
        memoryStorage.set(key, value);
      }
    } catch (e) {
      // Fallback to memory storage on any error
      memoryStorage.set(key, value);
    }
  }

  static getItem(key) {
    // console.log('getItem', key );
    try {
      if (gameStorage.isCrazyGames()) {
        return window.CrazyGames.SDK.data.getItem(key);
      } else if (gameStorage.isLocalStorageAvailable()) {
        return window.localStorage.getItem(key);
      } else {
        // Fallback to memory storage (incognito mode)
        return memoryStorage.get(key) || null;
      }
    } catch (e) {
      // Fallback to memory storage on any error
      return memoryStorage.get(key) || null;
    }
  }

  static removeItem(key) {
    // console.log('removeItem', key );
    try {
      if (gameStorage.isCrazyGames()) {
        window.CrazyGames.SDK.data.removeItem(key);
      } else if (gameStorage.isLocalStorageAvailable()) {
        window.localStorage.removeItem(key);
      } else {
        // Fallback to memory storage (incognito mode)
        memoryStorage.delete(key);
      }
    } catch (e) {
      // Fallback to memory storage on any error
      memoryStorage.delete(key);
    }
  }
}
