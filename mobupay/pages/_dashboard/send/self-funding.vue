<template>
  <div v-if="showUI">
    <div>
      <p>Fund Your Phone number</p>

      <NuxtLink
        :to="{
          name: 'dashboard',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
        >Dashboard</NuxtLink
      >

      <NuxtLink
        :to="{
          name: 'dashboard-send',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
      >
        &lt;&lt; Send Options</NuxtLink
      >
      <hr />
      <br />

      <div v-if="step == 'fund'">
        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-text-field autofocus v-model="form.amount" label="Amount">
            </v-text-field>
          </v-col>
        </v-row>

        <v-row align="center" v-if="showCards">
          <v-col class="d-flex" cols="12" sm="6">
            <v-select
              v-model="form.card"
              :items="cards"
              item-text="label"
              item-value="ref"
              hint="Ignore this field to fund from a new card"
              persistent-hint
              label="Select Card"
            ></v-select>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-btn @click="initiate_funding" elevation="2" outlined raised small
              >Proceed</v-btn
            >
          </v-col>
        </v-row>
      </div>

      <div v-if="step == 'verify'" class="verify">
        <div v-if="verifyingTransaction">Verifying...</div>
        <div v-else class="wrapperAlert">
          <div class="contentAlert">
            <div class="topHalf">
              <p>
                <svg viewBox="0 0 512 512" width="100" title="check-circle">
                  <path
                    d="M504 256c0 136.967-111.033 248-248 248S8 392.967 8 256 119.033 8 256 8s248 111.033 248 248zM227.314 387.314l184-184c6.248-6.248 6.248-16.379 0-22.627l-22.627-22.627c-6.248-6.249-16.379-6.249-22.628 0L216 308.118l-70.059-70.059c-6.248-6.248-16.379-6.248-22.628 0l-22.627 22.627c-6.248 6.248-6.248 16.379 0 22.627l104 104c6.249 6.249 16.379 6.249 22.628.001z"
                  />
                </svg>
              </p>
              <h1>Payment Successful</h1>

              <ul class="bg-bubbles">
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
              </ul>
            </div>

            <div class="bottomHalf">
              <p>
                Your Account has been funded with {{ transactionCurrency
                }}{{ transactionAmount | format_money }}
                <br />
                Current Balance: {{ transactionCurrency
                }}{{ newbalance | format_money }}
              </p>

              <NuxtLink
                :to="{
                  name: 'dashboard',
                  params: { dashboard: $auth.$state.user.msisdn },
                }"
              >
                <button id="alertMO">Dashboard</button>
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>

      <br />
      <hr />
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  middleware: "auth",
  name: "send",
  computed: mapGetters(["cards"]),
  data: () => ({
    showUI: false,
    verifyingTransaction: true,
    step: "fund",
    showCards: false,
    transactionAmount: "",
    transactionCurrency: "",
    newbalance: "",
    form: {
      card: "",
      amount: "",
      ip_address: "",
      device: "",
    },
  }),
  methods: {
    async initiate_funding() {
      let ip = await this.$axios.$get(process.env.ipURL);
      this.form.ip_address = ip.origin;
      this.form.device = window.navigator.userAgent;

      // if card is empty remove it from the request
      if (this.form.card.trim().length < 1) {
        delete this.form.card;
      }

      try {
        const response = await this.$axios.$post(
          "/transaction/send/self/initiate",
          this.form
        );

        switch (response.data.channel) {
          case "new_gateway":
            window.location.href = response.data.transaction.authorization_url;

            break;
          case "authorization_token":
            this.paymentSuccess(response.data);

            break;
        }
      } catch (error) {
        console.log("Request Error occured", error.response);
      }
    },
    setupCards() {
      if (this.cards.length > 0) {
        this.showCards = true;

        for (let index = 0; index < this.cards.length; index++) {
          const element = this.cards[index];
          element.label = `${element.bank} (${element.card_type})`;
        }
      }
    },
    async verifyTransaction(payload) {
      this.verifyingTransaction = true;
      try {
        const response = await this.$axios.post(
          "transaction/send/self/verify",
          payload
        );

        this.paymentSuccess(response.data.data);
      } catch (error) {
        console.log(error);
      }
    },
    paymentSuccess(data) {
      this.step = "verify";
      this.transactionAmount = data.transaction_amount;
      this.transactionCurrency = data.transaction_currency;
      this.newbalance = data.balance;
      this.$store.commit("updateBalance", data.balance);
      this.$store.commit("mayBeAddCard", data.card);
      this.verifyingTransaction = false;
    },
  },
  mounted() {
    this.setupCards();

    let route_params = this.$route.query;

    if (route_params.consolidator && route_params.reference) {
      this.step = "verify";
      this.showUI = true;
      this.verifyTransaction({
        consolidator: route_params.consolidator,
        ref: route_params.reference,
      });
    } else {
      this.step = "fund";
      this.showUI = true;
    }
  },
};
</script>

<style scoped>
/* successful payment  */
.verify {
  /* height: 100vh; */
  display: flex;
  font-size: 14px;
  text-align: center;
  justify-content: center;
  align-items: center;
  /* font-family: "Khand", sans-serif; */
}

.wrapperAlert {
  width: 500px;
  height: auto;
  overflow: hidden;
  border-radius: 12px;
  border: thin solid #ddd;
}

.topHalf {
  width: 100%;
  color: white;
  overflow: hidden;
  min-height: 250px;
  position: relative;
  padding: 40px 0;
  background: rgb(0, 0, 0);
  background: -webkit-linear-gradient(45deg, #019871, #a0ebcf);
}

.topHalf p {
  margin-bottom: 30px;
}
svg {
  fill: white;
}
.topHalf h1 {
  font-size: 2.25rem;
  display: block;
  font-weight: 500;
  letter-spacing: 0.15rem;
  text-shadow: 0 2px rgba(128, 128, 128, 0.6);
}

/* Original Author of Bubbles Animation -- https://codepen.io/Lewitje/pen/BNNJjo */
.bg-bubbles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

li {
  position: absolute;
  list-style: none;
  display: block;
  width: 40px;
  height: 40px;
  background-color: rgba(255, 255, 255, 0.15); /* fade(green, 75%);*/
  bottom: -160px;

  -webkit-animation: square 20s infinite;
  animation: square 20s infinite;

  -webkit-transition-timing-function: linear;
  transition-timing-function: linear;
}
li:nth-child(1) {
  left: 10%;
}
li:nth-child(2) {
  left: 20%;

  width: 80px;
  height: 80px;

  animation-delay: 2s;
  animation-duration: 17s;
}
li:nth-child(3) {
  left: 25%;
  animation-delay: 4s;
}
li:nth-child(4) {
  left: 40%;
  width: 60px;
  height: 60px;

  animation-duration: 22s;

  background-color: rgba(white, 0.3); /* fade(white, 25%); */
}
li:nth-child(5) {
  left: 70%;
}
li:nth-child(6) {
  left: 80%;
  width: 120px;
  height: 120px;

  animation-delay: 3s;
  background-color: rgba(white, 0.2); /* fade(white, 20%); */
}
li:nth-child(7) {
  left: 32%;
  width: 160px;
  height: 160px;

  animation-delay: 7s;
}
li:nth-child(8) {
  left: 55%;
  width: 20px;
  height: 20px;

  animation-delay: 15s;
  animation-duration: 40s;
}
li:nth-child(9) {
  left: 25%;
  width: 10px;
  height: 10px;

  animation-delay: 2s;
  animation-duration: 40s;
  background-color: rgba(white, 0.3); /*fade(white, 30%);*/
}
li:nth-child(10) {
  left: 90%;
  width: 160px;
  height: 160px;

  animation-delay: 11s;
}

@-webkit-keyframes square {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-500px) rotate(600deg);
  }
}
@keyframes square {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-500px) rotate(600deg);
  }
}

.bottomHalf {
  align-items: center;
  padding: 35px;
}
.bottomHalf p {
  font-weight: 500;
  font-size: 1.05rem;
  margin-bottom: 20px;
}

button {
  border: none;
  color: white;
  cursor: pointer;
  border-radius: 12px;
  padding: 10px 18px;
  background-color: #019871;
  text-shadow: 0 1px rgba(128, 128, 128, 0.75);
}
button:hover {
  background-color: #85ddbf;
}
</style>