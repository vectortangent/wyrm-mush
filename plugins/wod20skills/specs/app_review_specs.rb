module AresMUSH
  module WOD20Skills
    describe WOD20Skills do

      before do
        stub_translate_for_testing
      end

      describe :backgrounds do
        before do
          allow(Global).to receive(:read_config).with("wod20skills", "min_backgrounds") { 2 }
          @char = double
        end

        it "should error if too few bg skills" do
          allow(@char).to receive(:wod20_background_skills) { [ WOD20BackgroundSkill.new() ] }
          review = WOD20Skills.backgrounds_review(@char)
          expect(review).to eq "wod20skills.backgrounds_added                        chargen.not_enough"
        end

        it "should be OK if enough bg skills" do
          allow(@char).to receive(:wod20_background_skills) { [ WOD20BackgroundSkill.new(), WOD20BackgroundSkill.new() ] }
          review = WOD20Skills.backgrounds_review(@char)
          expect(review).to eq "wod20skills.backgrounds_added                        chargen.ok"
        end
      end

      describe :ability_rating_check do
        before do
          allow(Global).to receive(:read_config).with("wod20skills", "max_skills_at_or_above") { { 5 => 2, 7 => 1 } }
          allow(Global).to receive(:read_config).with("wod20skills", "max_attrs_at_or_above") { { 4 => 2, 5 => 1 } }
          allow(Global).to receive(:read_config).with("wod20skills", "max_points_on_attrs") { 14 }
          allow(Global).to receive(:read_config).with("wod20skills", "max_points_on_action") { 20 }
          allow(Global).to receive(:read_config).with("wod20skills", "max_points_on_advantages") { 10 }
          allow(Global).to receive(:read_config).with("wod20skills", "advantages_cost") { 2 }
          @char = double
        end

        it "should error if too many skills above 6" do
          allow(@char).to receive(:wod20_attributes) { [] }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(rating: 7),
                                             WOD20ActionSkill.new(rating: 8) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.action_skills_above"
        end

        it "should error if too many skills above 4" do
          allow(@char).to receive(:wod20_attributes) { [] }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(rating: 7),
                                             WOD20ActionSkill.new(rating: 5),
                                             WOD20ActionSkill.new(rating: 5) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.action_skills_above"
        end

        it "should error if too many points on attrs" do
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(@char).to receive(:wod20_attributes) { [ WOD20Attribute.new(rating: 3),
                                             WOD20Attribute.new(rating: 4),
                                             WOD20Attribute.new(rating: 3),
                                             WOD20Attribute.new(rating: 3),
                                             WOD20Attribute.new(rating: 4),
                                             WOD20Attribute.new(rating: 3) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.too_many_attributes"
        end

        it "should error if too many points on action skills" do
          allow(@char).to receive(:wod20_attributes) { [] }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(rating: 7),
                                             WOD20ActionSkill.new(rating: 5),
                                             WOD20ActionSkill.new(rating: 4),
                                             WOD20ActionSkill.new(rating: 4),
                                             WOD20ActionSkill.new(rating: 4),
                                             WOD20ActionSkill.new(rating: 4) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.too_many_action_skills"
        end


        it "should error if too many points on advs" do
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(@char).to receive(:wod20_attributes) { [] }
          allow(@char).to receive(:wod20_advantages) { [ WOD20Advantage.new(rating: 3),
                                             WOD20Advantage.new(rating: 2),
                                             WOD20Advantage.new(rating: 1) ] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.too_many_advantages"
        end

        it "should error if too many attrs above 3" do
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(@char).to receive(:wod20_attributes) { [ WOD20Attribute.new(rating: 4),
                                             WOD20Attribute.new(rating: 4),
                                             WOD20Attribute.new(rating: 5) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.attributes_above"
        end

        it "should error if too many attrs above 4" do
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(@char).to receive(:wod20_attributes) { [ WOD20Attribute.new(rating: 5),
                                             WOD20Attribute.new(rating: 5) ] }
          allow(@char).to receive(:wod20_advantages) { [] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check%r%Twod20skills.attributes_above"
        end

        it "should be OK if not too many high abilities" do
          allow(@char).to receive(:wod20_attributes) { [ WOD20Attribute.new(rating: 3),
                                             WOD20Attribute.new(rating: 4),
                                             WOD20Attribute.new(rating: 2) ] }
         allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(rating: 7),
                                            WOD20ActionSkill.new(rating: 4),
                                            WOD20ActionSkill.new(rating: 3) ] }
          allow(@char).to receive(:wod20_advantages) { [ WOD20Advantage.new(rating: 3),
                                             WOD20Advantage.new(rating: 2) ] }
          review = WOD20Skills.ability_rating_review(@char)
          expect(review).to eq "wod20skills.ability_ratings_check                    chargen.ok"
        end
      end

      describe :starting_skills_check do
        before do
          @char = double
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(StartingSkills).to receive(:get_skills_for_char) { { "A" => 2, "B" => 3 }}
          allow(StartingSkills).to receive(:get_specialties_for_char) { { "A" => [ "X" ] }}
          allow(WOD20Skills).to receive(:ability_rating).with(@char, "A") { 3 }
          allow(WOD20Skills).to receive(:ability_rating).with(@char, "B") { 3 }
          allow(WOD20Skills).to receive(:action_skill_config) { {} }
        end

        it "should warn if missing a starting skill" do
          allow(WOD20Skills).to receive(:ability_rating).with(@char, "B") { 0 }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check%r%Twod20skills.missing_starting_skill"
        end

        it "should be OK if all skills present" do
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check                    chargen.ok"
        end

        it "should warn if missing a required specialty and over amateur" do
          config = { "specialties" => [ "A" ] }
          allow(WOD20Skills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "Firearms", rating: 3)] }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check%r%Twod20skills.missing_specialty"
        end

        it "should warn if missing a required specialty and under amateur" do
          config = { "specialties" => [ "A" ] }
          allow(WOD20Skills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "Firearms", rating: 2)] }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check                    chargen.ok"
        end

        it "should be OK if specialty present" do
          config = { "specialties" => [ "A" ] }
          allow(WOD20Skills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "Firearms", specialties: [ "X" ])] }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check                    chargen.ok"
        end

        it "should warn if missing group specialty" do
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "A", rating: 3)] }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check%r%Twod20skills.missing_group_specialty"
        end

        it "should not warn if group specialty present" do
          skill = WOD20ActionSkill.new(name: "A", rating: 3, specialties: [ 'X' ])
          allow(@char).to receive(:wod20_action_skills) { [ skill ] }
          review = WOD20Skills.starting_skills_check(@char)
          expect(review).to eq "wod20skills.starting_skills_check                    chargen.ok"
        end
      end


      describe :unusual_skills_check do
        before do
          @char = double
          allow(@char).to receive(:wod20_background_skills) { [] }
          allow(@char).to receive(:wod20_action_skills) { [] }
          allow(@char).to receive(:wod20_languages) { [] }
          allow(Global).to receive(:read_config).with("wod20skills", "unusual_skills") { [ "A" ] }
        end

        it "should warn if char has an unusual action skill above everyman" do
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "A", rating: 2) ] }
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check%r%Twod20skills.unusual_skill"
        end

        it "should not warn if char has an unusual action skill at everyman" do
          allow(@char).to receive(:wod20_action_skills) { [ WOD20ActionSkill.new(name: "A", rating: 1) ] }
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check                  chargen.ok"
        end

        it "should warn if char has an unusual background skill" do
          allow(@char).to receive(:wod20_background_skills) { [ WOD20BackgroundSkill.new(name: "A", rating: 1) ] }
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check%r%Twod20skills.unusual_skill"
        end

        it "should warn if char has an unusual language skill" do
          allow(@char).to receive(:wod20_languages) { [ WOD20Language.new(name: "A", rating: 1) ] }
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check%r%Twod20skills.unusual_skill"
        end

        it "should warn if char has a high background skill" do
          allow(@char).to receive(:wod20_background_skills) { [ WOD20BackgroundSkill.new(name: "B", rating: 2)]}
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check%r%Twod20skills.high_bg"
        end

        it "should be OK if no unusual skills present" do
          review = WOD20Skills.unusual_skills_check(@char)
          expect(review).to eq "wod20skills.unusual_abilities_check                  chargen.ok"
        end

      end

    end
  end
end
