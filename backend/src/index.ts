import express , {type Request , type Response} from 'express';
import cors from 'cors';
import dotenv from 'dotenv';


dotenv.config();

const app = express();

const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

app.get("/api/health",(req:Request,res:Response)=>{
    res.status(200).json({
        message:"successully running server"
    })
});

app.listen(PORT,()=>{
    console.log(`server is running on ${PORT}`);
});

