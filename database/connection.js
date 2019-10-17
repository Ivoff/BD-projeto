const metaData = require("../helpers/metaDataObject");
const generate = require("../helpers/generateSql");
require('dotenv').config();

const {Pool, Client} = require('pg');

module.exports = function () {
    const client = new Client(
        {
            user: process.env.DB_USERNAME,
            host: process.env.HOST,
            database: process.env.DB_DATABASE,
            password: process.env.PGPASSWORD,
            port: process.env.PORT,
        }
    );

    return {
        commit: () => {

        },

        closeConnectionAsync: async () => {
            await client.end();
            console.log("disconneted");
        },

        insertAsync: async (option) => {
            let sql = generate(option);

            let data = metaData.getValues(option.object);

            return (await client
                .query(sql, data)).rows[0]
        },

        createConnectionAsync: async () => {
            try {
                await client.connect();
                console.log("connected")
            }catch (e) {
                console.error('connection error', e.stack)
            }
        }
    }
};