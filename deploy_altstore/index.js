const fs = require('node:fs');
const path = require('node:path');

const exampleFilePath = path.join(__dirname, '../assets/altstore/example.json');
const ipaFilePath = path.join(__dirname, '../all-dist/ios-build/bili_garb-ios.ipa');
const outputFilePath = path.join(__dirname, './public/index.html');

const main = () => {
  const buildName = process.argv.slice(2)[0]; // 1.0.0
  const buildNumber = process.argv.slice(2)[1]; // 1

  const stats = fs.statSync(ipaFilePath);
  const data = JSON.parse(fs.readFileSync(exampleFilePath, 'utf-8'));
  data.apps[0].versions[0] = {
    version: buildName,
    buildVersion: buildNumber,
    date: new Date().toISOString(),
    localizedDescription: "这是新的版本喵~",
    downloadURL: `https://alt-r2.cfm.moe/${buildName}_${buildNumber}/bili_garb-ios.ipa`,
    size: stats.size
  }
  fs.writeFileSync(outputFilePath, JSON.stringify(data), 'utf-8');
}
main();
