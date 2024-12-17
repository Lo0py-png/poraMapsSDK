package mk.upsy.app

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class NavigationStepsAdapter(
    private val steps: List<NavigationStep>,
    private val onStepClick: (NavigationStep) -> Unit
) : RecyclerView.Adapter<NavigationStepsAdapter.StepViewHolder>() {

    inner class StepViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val instructionTextView: TextView = itemView.findViewById(R.id.text_view_instruction)
        val distanceDurationTextView: TextView = itemView.findViewById(R.id.text_view_distance_duration)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StepViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_navigation_step, parent, false)
        return StepViewHolder(view)
    }

    override fun onBindViewHolder(holder: StepViewHolder, position: Int) {
        val step = steps[position]
        holder.instructionTextView.text = "${position + 1}. ${step.instructions}"
        holder.distanceDurationTextView.text = "${step.distance} · ${step.duration}"

        holder.itemView.setOnClickListener {
            onStepClick(step)
        }
    }

    override fun getItemCount(): Int = steps.size
}
