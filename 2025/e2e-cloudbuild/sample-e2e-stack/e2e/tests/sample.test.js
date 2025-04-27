// @ts-check
const { test, expect } = require('@playwright/test');

test('メッセージボードの基本機能テスト', async ({ page }) => {
  // アプリにアクセス（コンテナ名で実接続先の解決が可能）
  await page.goto('http://myapp:8080');

  // タイトルの確認
  await expect(page).toHaveTitle('シンプルメッセージボード');

  // メッセージを投稿
  const testMessage = 'これはテストメッセージです - ' + new Date().toISOString();
  await page.fill('input[name="content"]', testMessage);
  await page.click('input[type="submit"]');

  // 投稿したメッセージが表示されることを確認
  await expect(page.locator('.message >> text=' + testMessage)).toBeVisible();
});
