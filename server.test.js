const request = require("supertest");
const app = require("./server"); // make sure server.js exports app

test("GET / should return 200", async () => {
  const res = await request(app).get("/");
  expect(res.statusCode).toBe(200);
});

