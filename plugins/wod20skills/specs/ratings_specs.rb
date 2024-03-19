module AresMUSH
  module WOD20Skills
    describe WOD20Skills do

      before do
        allow(WOD20Skills).to receive(:attr_names) { [ "Brawn", "Mind" ] }
        allow(WOD20Skills).to receive(:action_skill_names) { [ "Firearms", "Demolitions" ] }
        allow(WOD20Skills).to receive(:language_names) { [ "English", "Spanish" ] }
        allow(WOD20Skills).to receive(:advantage_names) { [ "Rank", "Resources" ] }
      end

      describe :ability_rating do
        before do
          @char = double
          @languages = double
          @action_skills = double
          @bg_skills = double
          @attrs = double
          @advantages = double

          allow(@advantages).to receive(:find).with(name: "Resources") { [] }
          allow(@advantages).to receive(:find).with(name: "Rank") { [ WOD20Advantage.new(name: "Rank", rating: 3 ) ]}

          allow(@languages).to receive(:find).with(name: "Spanish") { [] }
          allow(@languages).to receive(:find).with(name: "English") { [ WOD20Language.new(name: "English", rating: 1 ) ] }

          allow(@action_skills).to receive(:find).with(name: "Firearms") {[ WOD20ActionSkill.new(name: "Firearms", rating: 2 )] }
          allow(@action_skills).to receive(:find).with(name: "Demolitions") { [] }

          allow(@bg_skills).to receive(:find).with(name: "Basketweaving") { [ WOD20BackgroundSkill.new(name: "Basketweaving", rating: 3 )] }
          allow(@bg_skills).to receive(:find).with(name: "Art") { [] }

          allow(@attrs).to receive(:find).with(name: "Brawn") { [ WOD20Attribute.new(name: "Brawn", rating: 4 )] }
          allow(@attrs).to receive(:find).with(name: "Mind") { [] }

          allow(@char).to receive(:wod20_languages) { @languages }
          allow(@char).to receive(:wod20_attributes) { @attrs }
          allow(@char).to receive(:wod20_action_skills) { @action_skills }
          allow(@char).to receive(:wod20_background_skills) { @bg_skills }
          allow(@char).to receive(:wod20_advantages) { @advantages }
        end

        it "should get skills that exist" do
          expect(WOD20Skills.ability_rating(@char, "English")).to eq 1
          expect(WOD20Skills.ability_rating(@char, "Firearms")).to eq 2
          expect(WOD20Skills.ability_rating(@char, "Basketweaving")).to eq 3
          expect(WOD20Skills.ability_rating(@char, "Brawn")).to eq 4
          expect(WOD20Skills.ability_rating(@char, "Rank")).to eq 3
        end

        it "should get skills that don't exit" do
          expect(WOD20Skills.ability_rating(@char, "Spanish")).to eq 0
          expect(WOD20Skills.ability_rating(@char, "Demolitions")).to eq 0
          expect(WOD20Skills.ability_rating(@char, "Mind")).to eq 0
          expect(WOD20Skills.ability_rating(@char, "Art")).to eq 0
          expect(WOD20Skills.ability_rating(@char, "Resources")).to eq 0
        end

        it "should not search background skills for an action skill" do
          allow(@bg_skills).to receive(:find).with(name: "Demolitions") { [ WOD20BackgroundSkill.new(name: "Demolitions", rating: 3 )] }
          expect(WOD20Skills.ability_rating(@char, "Demolitions")).to eq 0
        end

        it "should not search background skills for a language" do
          allow(@bg_skills).to receive(:find).with(name: "Spanish") { [ WOD20BackgroundSkill.new(name: "Spanish", rating: 3 )] }
          expect(WOD20Skills.ability_rating(@char, "Spanish")).to eq 0
        end
      end

      describe :get_linked_attr do
        before do
          skills = [ { "name" => "Firearms", "linked_attr" => "Brawn" } ]
          allow(Global).to receive(:read_config).with("wod20skills", "default_linked_attr") { "Wits" }
          allow(Global).to receive(:read_config).with("wod20skills", "action_skills") { skills }

        end

        it "should get linked for an action skill from the skill config" do
          expect(WOD20Skills.get_linked_attr("Firearms")).to eq "Brawn"
        end

        it "should return nothing for attribute" do
          expect(WOD20Skills.get_linked_attr("Mind")).to be_nil
        end

        it "should default for langs and background skills" do
          expect(WOD20Skills.get_linked_attr("Basketweaving")).to eq "Wits"
          expect(WOD20Skills.get_linked_attr("Spanish")).to eq "Wits"
        end

        it "should default for advantages" do
          expect(WOD20Skills.get_linked_attr("Rank")).to eq "Wits"
        end

      end
    end
  end
end
