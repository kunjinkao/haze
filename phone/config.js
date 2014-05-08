module.exports = {
  webPort: 80,
  oscPort: 9000,
  pages: [
    { rootUrl: '/', dirName: './app' }
  ],
  clients: [
    { ip: '127.0.0.1', appPort: 9001 },
    { ip: '127.0.0.1', appPort: 12000 },
    { ip: '192.168.1.100', appPort: 12000 },
    { ip: '192.168.1.101', appPort: 12000 },
    { ip: '192.168.1.102', appPort: 12000 }    
  ]
}