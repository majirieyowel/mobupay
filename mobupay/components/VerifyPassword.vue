<template>
  <v-dialog v-model="show" width="500" persistent>
    <v-card>
      <v-card-title class="text-h6 primary">
        <div class="d-flex justify-space-between w-100">
          <span class="title--text">Enter your password </span>
          <span @click="close" class="close">&times;</span>
        </div>
      </v-card-title>

      <v-card-text>
        <v-row class="mt-6 justify-center">
          <v-col cols="6">
            <v-text-field
              v-model="form.password"
              onfocus
              :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              :type="showPassword ? 'text' : 'password'"
              @click:append="showPassword = !showPassword"
            ></v-text-field>
          </v-col>
        </v-row>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <div class="mb-4">
          <v-btn
            color="#0052ff"
            :loading="verifyingPassword"
            class="ma-1"
            tile
            @click="verifyPassword"
          >
            Verify Password
          </v-btn>
        </div>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "verify_password",
  emits: ["close", "successful"],
  data: () => ({
    verifyingPassword: false,
    showPassword: false,
    form: {
      password: "",
      // password: "@Nelie&e12",
    },
  }),
  props: {
    show: Boolean,
  },
  methods: {
    async verifyPassword() {
      this.verifyingPassword = true;
      try {
        const response = await this.$axios.$post(
          "user/verify-password",
          this.form
        );

        if (response.data.allow) {
          this.$emit("successful");
        } else {
          this.$toast.error(
            "Your account may be temp blocked feature coming soon... keep trying lol!"
          );
        }

        this.verifyingPassword = false;
      } catch (error) {
        this.verifyingPassword = false;

        this.$toast.error("keep trying lol!");
      }
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>

<style lang="scss" scoped>
.close {
  cursor: pointer;
}
.title--text {
  color: $white;
}

.v-btn {
  color: $white;
}

.w-100 {
  width: 100%;
}
</style>